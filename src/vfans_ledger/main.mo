import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Float "mo:base/Float";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import icp_ledger_canister "../lib/icp_ledger_canister";
import icp_rate "../lib/icp_rate";
import Cycles "mo:base/ExperimentalCycles";
import Int "mo:base/Int";
import List "mo:base/List";
import Bool "mo:base/Bool";
import Time "mo:base/Time";
import Int64 "mo:base/Int64";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Set "../lib/Set";
import LogUtil "../lib/LogUtil";
import TimeUtil "../lib/TimeUtil";
import NumberUtil "../lib/NumberUtil";
import SignUtil "../lib/SignUtil";
import Hex "../lib/Hex";
import Types "../http_get/Types";
import TransferType "libs/TransferType";
import TextUtils "libs/TextUtils";

actor  class X()=this  {
  type icp_ledger_canister_ = icp_ledger_canister.Self;
  type icp_rate_ = icp_rate.Self;
  let icp_ledger_canister_holder : icp_ledger_canister_ = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");
  let icp_rate_holder : icp_rate_ = actor ("uf6dk-hyaaa-aaaaq-qaaaq-cai");
  stable var log_list : LogUtil.LogSet = List.nil<LogUtil.Log>();
  type blob = Blob;
  type principal = Principal;
  type nat = Nat;
  type nat64 = Nat64;
  public type VfansInfo = TransferType.VfansInfo;
  public type VfansInfoRead = TransferType.VfansInfoRead;
  type Tokens = TransferType.Tokens;
  type text = Text;
  type tokens = { e8s : Nat64 };
  type TextAccountIdentifier = text;
  type AccountBalanceArgsDfx = { account : TextAccountIdentifier };
  type TransferArgs = TransferType.TransferArgs;
  type ProxyTransferArgs = TransferType.ProxyTransferArgs;
  type Account = TransferType.Account;
  public type ApproveArgs =TransferType.ApproveArgs;
  public type Rate = TransferType.Rate;
  public type RateRecord = TransferType.RateRecord;
  public type VftTransactionLogs = TransferType.VftTransactionLogs;
  public type VftTransactionLog = TransferType.VftTransactionLog; //icp_transaction_second_log
  public type IcpTransactionSecondLogs = TransferType.IcpTransactionSecondLogs;
  var icp_transaction_second_logs = HashMap.HashMap<Text,List.List<IcpTransactionSecondLogs>>(0, Text.equal, Text.hash);
  private stable var icp_transaction_second_entries : [(Text, List.List<IcpTransactionSecondLogs>)] = [];


  stable let vfansInfo : VfansInfo = {
    var vft_issue_toal_amount = 0;
    var vft_destyoy_toal_amount = 0;
    var exchange_VFT_amount = 0;
    var exchange_RMB_amount = 0;
    var exchange_ICP_amount = 0;
    var hold_ICP_account = List.nil<Text>();
    var exchang_total_count = 0;
    var exchang_total_ICP_amount = 0;
    var inventory_icp_amount = 0;
  };

  stable var tlogs : VftTransactionLogs = List.nil<VftTransactionLog>();

  stable let rate_rmb_cache : Rate = {
    var rate = 0;
    var yesterday_rate = 0;
    var update_time = 0;
    currency_type = {
      symbol = "CNY";
      class_ = #FiatCurrency;
    };
  };


  stable let rate_usd_cache : Rate = {
    var rate = 0;
    var yesterday_rate = 0;
    var update_time = 0;
    currency_type = {
      symbol = "USD";
      class_ = #FiatCurrency;
    };
  };

  public query func query_balance() : async Nat {
    return Cycles.balance();
  };

  //查询兑换比例
  /// Extract the current exchange rate for the given symbol.
  public shared func get_exchange_rate_rmb(refresh : Bool) : async RateRecord {
    // let base : icp_rate.Asset = { symbol = "ICP"; class_ = #Cryptocurrency };
    let quote : icp_rate.Asset = { symbol = "CNY"; class_ = #FiatCurrency };
    return await get_exchange_rate(quote, refresh);
  };
  public shared func get_exchange_rate_usd(refresh : Bool) : async RateRecord {
    // let base : icp_rate.Asset = { symbol = "ICP"; class_ = #Cryptocurrency };
    let quote : icp_rate.Asset = { symbol = "USD"; class_ = #FiatCurrency };
    return await get_exchange_rate(quote, refresh);
  };
  public shared func get_exchange_rate(quote : icp_rate.Asset, refresh : Bool) : async RateRecord {
    return await do_get_exchange_rate(quote, refresh);
  };
  public func get_log() : async LogUtil.LogSet {
    return log_list;
  };

  public shared func init_exchang_total_count(count:Nat): async Nat {
    vfansInfo.exchang_total_count:=count;
    return vfansInfo.exchang_total_count;
  };

  public shared func do_get_exchange_rate(quote : icp_rate.Asset, refresh : Bool) : async RateRecord {
    let time=TimeUtil.getCurrentSecond();
    if ((not refresh) and cacheEffective(quote)) {
      if (quote == rate_usd_cache.currency_type) {
        return {
          rate = rate_usd_cache.rate;
          yesterday_rate = rate_usd_cache.yesterday_rate;
          update_time = rate_usd_cache.update_time;
          currency_type = rate_usd_cache.currency_type;
        };
      } else {
        return {
          rate = rate_rmb_cache.rate;
          update_time = rate_rmb_cache.update_time;
          yesterday_rate = rate_rmb_cache.yesterday_rate;
          currency_type = rate_rmb_cache.currency_type;
        };
      };
    };

    let request : icp_rate.GetExchangeRateRequest = {
      // base_asset = base;
      quote_asset = quote;
      base_asset = {
        symbol = "ICP";
        class_ = #Cryptocurrency;
      };
      timestamp = ?Nat64.fromIntWrap(time);
    };
    let yesterday = time -(60 * 60 * 24);
    let request2 : icp_rate.GetExchangeRateRequest = {
      // base_asset = base;
      quote_asset = quote;
      base_asset = {
        symbol = "ICP";
        class_ = #Cryptocurrency;
      };
      timestamp = ?Nat64.fromIntWrap(yesterday);
    };

    // Every XRC call needs 1B cycles.
    Cycles.add<system>(1_000_000_000);
    let feature = icp_rate_holder.get_exchange_rate(request);
    Cycles.add<system>(1_000_000_000);
    //    let response2=response;
    let feature2 = icp_rate_holder.get_exchange_rate(request2);
    // Print out the response to get a detailed view.
    // return (debug_show (response));
    // Return 0.0 if there is an error for the sake of simplicity.
    var rate : Float = 0;
    var rate2 : Float = 0;

    let response = await feature;
    let response2 = await feature2;
    switch (response) {
      case (#Ok(rate_response)) {
        let float_rate = Float.fromInt(Nat64.toNat(rate_response.rate));
        let float_divisor = Float.fromInt(Nat32.toNat(10 ** rate_response.metadata.decimals));
        rate := float_rate / float_divisor;
      };
      // return result;
      case (#Err(error)) {
        log_list := LogUtil.add_log(log_list, #query_icp_rate, icp_rate.getExchangeRateErrorText(error));
        return {
          rate = 0;
          yesterday_rate = 0;
          update_time = 0;
          currency_type = quote;
        };
      };
    };
    switch (response2) {
      case (#Ok(rate_response)) {
        let float_rate = Float.fromInt(Nat64.toNat(rate_response.rate));
        let float_divisor = Float.fromInt(Nat32.toNat(10 ** rate_response.metadata.decimals));
        rate2 := float_rate / float_divisor;
      };
      // return result;
      case (#Err(error)) {
        log_list := LogUtil.add_log(log_list, #query_icp_rate, icp_rate.getExchangeRateErrorText(error));
        return {
          rate = 0;
          yesterday_rate = 0;
          update_time = 0;
          currency_type = quote;
        };
      };
    };

    let timestamp : Int = getCurrentSecond();
    if (quote == rate_usd_cache.currency_type) {
      rate_usd_cache.rate := rate;
      rate_usd_cache.yesterday_rate := rate2;
      rate_usd_cache.update_time := timestamp;
      return {
        rate = rate_usd_cache.rate;
        yesterday_rate = rate2;
        update_time = rate_usd_cache.update_time;
        currency_type = rate_usd_cache.currency_type;
      };
    } else {
      rate_rmb_cache.update_time := timestamp;
      rate_rmb_cache.rate := rate;
      rate_rmb_cache.yesterday_rate := rate2;
      return {
        rate = rate_rmb_cache.rate;
        yesterday_rate = rate2;
        update_time = rate_rmb_cache.update_time;
        currency_type = rate_rmb_cache.currency_type;
      };
    };
  };

  private func cacheEffective(query_type : icp_rate.Asset) : Bool {

    var last_time : Int = 0;
    if (query_type == rate_usd_cache.currency_type) {
      if (rate_usd_cache.rate == 0) {
        return false;
      };
      last_time := rate_usd_cache.update_time;
    } else {
      if (rate_rmb_cache.rate == 0) {
        return false;
      };
      last_time := rate_rmb_cache.update_time;
    };
    return (last_time +600) > getCurrentSecond();
  };

  private func getCurrentSecond() : Int {
    return (Time.now() / 1_000_000_000);
  };

  //查询ICP余额
  public shared func queryICP(accountId : Text) : async tokens {
    let reqParam : AccountBalanceArgsDfx = { account = accountId };
    return await icp_ledger_canister_holder.account_balance_dfx(reqParam);
  };

  public shared func init_inventory_icp_amount() : async Nat {
      vfansInfo.inventory_icp_amount := await icp_ledger_canister_holder.icrc1_balance_of({owner = Principal.fromActor(this);subaccount = null});
      return vfansInfo.inventory_icp_amount;
  };

  //查询ICP余额
  public query func queryVfanInfo() : async VfansInfoRead {
    return {
      vft_issue_toal_amount = vfansInfo.vft_issue_toal_amount;
      vft_destyoy_toal_amount = vfansInfo.vft_destyoy_toal_amount;
      exchange_VFT_amount = vfansInfo.exchange_VFT_amount;
      exchange_RMB_amount = vfansInfo.exchange_RMB_amount;
      exchange_ICP_amount = vfansInfo.exchange_ICP_amount;
      hold_ICP_account_count = List.size(vfansInfo.hold_ICP_account);
      exchang_total_count = vfansInfo.exchang_total_count;
      inventory_icp_amount = vfansInfo.inventory_icp_amount;
      exchang_total_ICP_amount = vfansInfo.exchang_total_ICP_amount;
    };
  };

  func check_sign (param : ProxyTransferArgs) : Bool {
    return SignUtil.check_sign(get_proxy_transfer_sign_array(param),param.sign,"xxxx");
  };

  func get_proxy_transfer_sign_array (param : ProxyTransferArgs) : [Text] {
    let sign_arr=[param.fromPrincipal,param.toPrincipal,Float.toText(param.vftCount),Int.toText(param.time)];
    return sign_arr;
  };
  public shared ({ caller }) func query_sin_str(param : ProxyTransferArgs) : async Text {
      return SignUtil.get_sign_str(get_proxy_transfer_sign_array(param),"xxxx");
  };



  public func transfer_rmb(param : ProxyTransferArgs) :async Result.Result<Nat, Text> {
    // let ic : Types.IC = actor ("aaaaa-aa");

    let rmb_amount = param.vftCount / 3 ;
//    Cycles.add<system>(230_949_972_000);
//    let host = "";
//    let transform_context : Types.TransformContext = {
//      function = transform;
//      context = Blob.fromArray([]);
//    };
//    let http_response : Types.HttpResponsePayload = await ic.http_request({
//      url = host # "";
//      max_response_bytes = null; //optional for request
//      headers = [
//        { name = "Host"; value = host # ":443" },
//        { name = "User-Agent"; value = "exchange_rate_canister" },
//      ];
//      body = null; //optional for request
//      method = #post;
//      transform = ?transform_context;
//    });

//    if (http_response.status == 200) {
    vfansInfo.exchange_VFT_amount += param.vftCount;
    vfansInfo.exchange_RMB_amount += rmb_amount;
    vfansInfo.exchang_total_count += 1;
    tlogs := List.push<VftTransactionLog>({
      //
      from = param.fromPrincipal;
      to = param.toPrincipal;
      chain_id = 0;
      nickname = param.nickname;
        //日志ID
      log_id  = List.size(tlogs);
      // 事务类型
      log_type = #withdrawal_rmb;
      // 交易时间
      log_time = Time.now();
      // 交易金额
      log_amount  = rmb_amount;
      // vft 数量
      log_vft_count = param.vftCount;
    },tlogs);
    return #ok 200;
//    };
//    return #err("error code = " # Nat.toText(http_response.status));
  };
  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
      let transformed : Types.CanisterHttpResponsePayload = {
          status = raw.response.status;
          body = raw.response.body;
          headers = [
              {
                  name = "Content-Security-Policy";
                  value = "default-src 'self'";
              },
              { name = "Referrer-Policy"; value = "strict-origin" },
              { name = "Permissions-Policy"; value = "geolocation=(self)" },
              {
                  name = "Strict-Transport-Security";
                  value = "max-age=63072000";
              },
              { name = "X-Frame-Options"; value = "DENY" },
              { name = "X-Content-Type-Options"; value = "nosniff" },
          ];
      };
      transformed;
  };

  //代理转账
  public shared ({ caller }) func proxy_transfer(param : ProxyTransferArgs) : async Result.Result<Nat, Text> {
    
    if(not TimeUtil.checkTimeout(param.time)){
      return #err("时间超时");
    };
    
    if(not check_sign(param)){
      return #err("签名验证失败");
    };

    if(param.transfer_money_type == 1){
      return await transfer_rmb(param);
    };
    if(rate_rmb_cache.rate==0){
      return #err("获取汇率异常");
    };
    var amount=NumberUtil.getIcpK8s(param.vftCount,rate_rmb_cache.rate);
    if(amount<=10000){
      return #err("金额异常,可兑换ICP不足以支付手续费");
    };
    amount -=10000;
    if(vfansInfo.inventory_icp_amount < amount){
      return #err("库存不足,当前剩余库存" # Nat.toText(vfansInfo.inventory_icp_amount));
    };
    

    try {
      // initiate the transfer
      // initiate the transfer

      let transferResult = await icp_ledger_canister_holder.icrc1_transfer({
        to =  { owner = Principal.fromText(param.toPrincipal); subaccount = null };
        fee = null;
        memo = null;
        from_subaccount = null;
        created_at_time = null;
        amount = amount;
      });

      // check if the transfer was successfull
      switch (transferResult) {
        case (#Err(transferError)) {
          return #err("Couldn't transfer funds:\n" # debug_show (transferError));
        };
        case (#Ok(blockIndex)) {
          vfansInfo.exchang_total_count += 1;
          vfansInfo.exchang_total_ICP_amount += amount;
          vfansInfo.inventory_icp_amount -= amount;
          vfansInfo.hold_ICP_account := Set.add(param.toPrincipal, vfansInfo.hold_ICP_account);
          tlogs := List.push<VftTransactionLog>({
            from = param.fromPrincipal;
            to = param.toPrincipal;
            chain_id = blockIndex;
            nickname = param.nickname;
             //日志ID
            log_id  = List.size(tlogs);
            // 事务类型
            log_type = #withdrawal_icp;
            // 交易时间
            log_time = Time.now();
            // 交易金额
            log_amount  =  Float.fromInt(amount);
            // vft 数量
            log_vft_count = param.vftCount;
          },tlogs);
          return #ok amount;
        };
      };
    } catch (error : Error) {
      // catch any errors that might occur during the transfer
      return #err("Reject message: " # Error.message(error));
    };
    return #err("Couldn't transfer funds:\n 未知错误");
  };


    public query func show_vft_transaction_log():async [VftTransactionLog] {
      return List.toArray(tlogs);
    };

    public shared ({caller}) func add_icp_transaction_second_log(param : IcpTransactionSecondLogs):async Text {
      let ic_account_id = TextUtils.toAddress(caller);
      let values = icp_transaction_second_logs.get(ic_account_id);
      switch(values){
        case (null) {
          icp_transaction_second_logs.put(ic_account_id ,
            List.push<IcpTransactionSecondLogs>(param,List.nil<IcpTransactionSecondLogs>()));
        };
        case (?values) {
          icp_transaction_second_logs.put(ic_account_id,
            List.push<IcpTransactionSecondLogs>(param,values));
        };
      };
      return "ok";
    };
    public query ({caller}) func get_icp_transaction_second_log(ic_account_id:Text):async [IcpTransactionSecondLogs] {
      let find = icp_transaction_second_logs.get(ic_account_id);
      switch(find){
        case (null) {
          return [];
        };
        case (?find) {
          return List.toArray<IcpTransactionSecondLogs>(find);
        };
      }
    };
    public query ({caller}) func get_icp_transaction_second_log2():async [(Text, List.List<IcpTransactionSecondLogs>)] {
      return Iter.toArray(icp_transaction_second_logs.entries());
    };


//查询地址
public shared func get_address() : async Text {
 return TextUtils.toAddress(Principal.fromActor(this));
};


  // 转账-真正的转账
  public shared ({ caller }) func transfer(args : TransferArgs) : async Result.Result<Nat64, Text> {
    Debug.print(
      "Transferring "
      # debug_show (args.amount)
      # " tokens to principal "
      # debug_show (args.accountId)
    );

    let transferArgs : icp_ledger_canister.TransferArgs = {
      // can be used to distinguish between transactions
      memo = 0;
      // the amount we want to transfer
      amount = args.amount;
      // the ICP ledger charges 10_000 e8s for a transfer
      fee = { e8s = 10_000 };
      // we are transferring from the canisters default subaccount, therefore we don't need to specify it
      from_subaccount = null;
      // we take the principal and subaccount from the arguments and convert them into an account identifier
      // to = Blob.toArray(Principal.toLedgerAccount(args.toPrincipal, args.toSubaccount));
      // to = Principal.toLedgerAccount(args.toPrincipal, args.toSubaccount);
      to= args.accountId;
      // a timestamp indicating when the transaction was created by the caller; if it is not specified by the caller then this is set to the current ICP time
      created_at_time = null;
    };

    try {
      // initiate the transfer
      let transferResult = await icp_ledger_canister_holder.transfer(transferArgs);

      // check if the transfer was successfull
      switch (transferResult) {
        case (#Err(transferError)) {
          return #err("Couldn't transfer funds:\n" # debug_show (transferError));
        };
        case (#Ok(blockIndex)) { return #ok blockIndex };
      };
    } catch (error : Error) {
      // catch any errors that might occur during the transfer
      return #err("Reject message: " # Error.message(error));
    };
  };


  system func preupgrade() {
    icp_transaction_second_entries := Iter.toArray(icp_transaction_second_logs.entries());
  };

  system func postupgrade() {
    icp_transaction_second_logs := HashMap.fromIter<Text, List.List<IcpTransactionSecondLogs>>(
      Iter.fromArray<(Text, List.List<IcpTransactionSecondLogs>)>(icp_transaction_second_entries),
      Array.size(icp_transaction_second_entries),Text.equal,Text.hash);
    icp_transaction_second_entries := [];
  };

};
