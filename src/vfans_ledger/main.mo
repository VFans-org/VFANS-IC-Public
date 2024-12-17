import Debug "mo:base/Debug";
import Result "mo:base/Result";
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
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import LogUtil "../lib/LogUtil";
import TimeUtil "../lib/TimeUtil";
import NumberUtil "../lib/NumberUtil";
import SignUtil "../lib/SignUtil";
import LOGGER_ "../lib/LOGGER";
import Types "../http_get/Types";
import TransferType "libs/TransferType";
import TextUtils "libs/TextUtils";
import time "libs/time";
import VftTypes "libs/VftTypes";
import Set "mo:base/OrderedSet";
import Buffer "mo:base/Buffer";
import Config "../lib/Config";


actor  class X()=this  {
  let LOGGER : LOGGER_.Self = actor(Config.LOGGER_SERVICE_CANISTER_ID);
  type icp_ledger_canister_ = icp_ledger_canister.Self;
  type icp_rate_ = icp_rate.Self;
  let icp_ledger_canister_holder : icp_ledger_canister_ = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");
  let icp_rate_holder : icp_rate_ = actor ("uf6dk-hyaaa-aaaaq-qaaaq-cai");
  stable var log_list : LogUtil.LogSet = List.nil<LogUtil.Log>();
  type blob = Blob;
  type principal = Principal;
  type nat = Nat;
  type nat64 = Nat64;
  // public type VfansInfo = TransferType.VfansInfo;
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
  public type TokenPlanTask = VftTypes.TokenPlanTask;
  public type TokenPlanTaskView = VftTypes.TokenPlanTaskView;
  public type Result = VftTypes.Result;
  public type User = VftTypes.User;
  public type VftLogParam = VftTypes.VftLogParam;
  public type VftLog = VftTypes.VftLog;
  stable var enable_exchange_vft_amount : Float = 0;
  


  var userTableMap = HashMap.HashMap<Nat,User>(1000, Nat.equal, Hash.hash);
  stable var userTable : [User]=[]; 
  stable var tokenPlanTaskTable : [TokenPlanTask]= [
    {
        id  = 0;
        var name  = "发电卡";
        var code = "SBT_1";
        var amount = 4000000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 1;
        var name  = "新用户注册";
        var code = "register";
        var amount = 6000000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 2;
        var name  = "邀请好友注册";
        var code = "invite";
        var amount = 3000000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 3;
        var name  = "治理任务";
        var code = "work";
        var amount = 600000000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 5;
        var name  = "闪电卡";
        var code = "SBT_2";
        var amount = 40000000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 6;
        var name  = "雷电卡";
        var code = "SBT_3";
        var amount = 400000000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 7;
        var name  = "VFT兑换";
        var code = "withdraw";
        var amount = -1;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 8;
        var name  = "每订阅付费7元";
        var code = "pay7";
        var amount = 142857000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 9;
        var name  = "邀请朋友每订阅付费7元";
        var code = "invitePay";
        var amount = 142857000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 10;
        var name  = "创作者激活频道";
        var code = "activeChannel";
        var amount = 50000000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 11;
        var name  = "创作者每获得一位新订阅付费用户";
        var code = "acquireCustomer";
        var amount = 20000000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 12;
        var name  = "创作者每获得7元订阅收入";
        var code = "earn7";
        var amount = 428571000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 13;
        var name  = "空投卡";
        var code = "SBT_4";
        var amount = 300000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 14;
        var name  = "VFT兑换IC";
        var code = "ic_exchange";
        var amount = -100000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    },
    {
        id  = 15;
        var name  = "VFT兑换RMB";
        var code = "rmb_exchange";
        var amount = -100000000;
        var create_by = null;
        var create_time = null;
        var update_by = null;
        var update_time = null;
        var remark = null;
    }
];


  // stable let vfansInfo : VfansInfo = {
  //   var vft_issue_toal_amount = 0;
  //   var vft_destroy_toal_amount = 0;
  //   var exchange_VFT_amount = 0;
  //   var exchange_RMB_amount = 0;
  //   var exchange_ICP_amount = 0;
  //   var hold_ICP_account = List.nil<Text>();
  //   var exchang_total_count = 0;
  //   var exchang_total_ICP_amount = 0;
  //   var inventory_icp_amount = 0;
  // };

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

  // public shared func init_exchang_total_count(count:Nat,pwd:Text): async Nat {
  //   assert Config.SECRET_ADMIN == pwd;
  //   vfansInfo.exchang_total_count:=count;
  //   return vfansInfo.exchang_total_count;
  // };

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
    return (last_time + 3600) > getCurrentSecond();
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
      let inventory_icp_amount = await icp_ledger_canister_holder.icrc1_balance_of({owner = Principal.fromActor(this);subaccount = null});
      return inventory_icp_amount;
  };

  //查询ICP余额
  public func queryVfanInfo() : async VfansInfoRead {
    let  new_amount = await init_inventory_icp_amount();
    let info = TransferType.calculateVfansInfo(List.toArray<VftTransactionLog>(tlogs),userTableMap);
    return {
      vft_issue_toal_amount = info.vft_issue_toal_amount;
      vft_destroy_toal_amount = info.vft_destroy_toal_amount;
      exchange_VFT_amount = info.exchange_VFT_amount;
      exchange_RMB_amount = info.exchange_RMB_amount;
      exchange_ICP_amount = info.exchange_ICP_amount;
      hold_ICP_account_count = info.hold_ICP_account;
      exchang_total_count = info.exchang_total_count;
      inventory_icp_amount = new_amount;
      enable_exchange_vft_amount = enable_exchange_vft_amount;
    };
  };
  func check_sign (param : ProxyTransferArgs) : Bool {
    return SignUtil.check_sign(get_proxy_transfer_sign_array(param),param.sign,Config.SECRET_KEY);
  };

  func get_proxy_transfer_sign_array (param : ProxyTransferArgs) : [Text] {
    let sign_arr=[param.fromPrincipal,param.toPrincipal,Float.toText(param.vftCount),Int.toText(param.time)];
    return sign_arr;
  };
  public shared ({ caller }) func query_sin_str(param : ProxyTransferArgs) : async Text {
      return SignUtil.get_sign_str(get_proxy_transfer_sign_array(param),Config.SECRET_KEY);
  };


  public shared  ({caller}) func setEnable_exchange_vft_amount(vftCount:Float):async (){
      assert isAdmin(caller);
      enable_exchange_vft_amount := vftCount;
  };

  public func transfer_rmb(param : ProxyTransferArgs) :async Result.Result<Nat, Text> {
    let rmb_amount = param.vftCount / 3 ;
    // vfansInfo.exchange_VFT_amount += param.vftCount;
    // vfansInfo.exchange_RMB_amount += rmb_amount;
    // vfansInfo.exchang_total_count += 1;
    enable_exchange_vft_amount -= param.vftCount;
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

  //代理转账0001
  public shared ({ caller }) func proxy_transfer(param : ProxyTransferArgs) : async Result.Result<Nat, Text> {
    if (enable_exchange_vft_amount  < param.vftCount){
      return #err("vft可兑换金额不足 enable_exchange_vft_amount = " # Float.toText(enable_exchange_vft_amount));
    };
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
    let inventory_icp_amount = await init_inventory_icp_amount();
    if(inventory_icp_amount < amount){
      return #err("库存不足,当前剩余库存" # Nat.toText(inventory_icp_amount));
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
          // vfansInfo.exchang_total_count += 1;
          // vfansInfo.exchang_total_ICP_amount += amount;
          // vfansInfo.inventory_icp_amount -= amount;
          // vfansInfo.hold_ICP_account := VftTypes.addIfNotExist(param.toPrincipal, vfansInfo.hold_ICP_account);
          enable_exchange_vft_amount -= param.vftCount;
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

  // ----------------------------20241122-------------------------------------------------


  public query func getTokenPlanTaskTable(): async [TokenPlanTaskView] {
    return VftTypes.to_views(tokenPlanTaskTable);
  };


  public shared func updateTokenPlanTaskTable(id:Nat,amount:Int,remark:?Text,sign:Text): async Result  {

    let check = SignUtil.check_sign([Nat.toText(id),Int.toText(amount)],sign,Config.SECRET_KEY);
    if(not check){
      return {
        code=501;
        msg="签名错误";
      };
    };


    let find = Array.find<TokenPlanTask>(tokenPlanTaskTable,func(item:TokenPlanTask):Bool{
      return item.id == id;
    });
    switch(find){
      case (null) {
        return {
          code=1;
          msg="未找到记录 id = " # Nat.toText(id);
        };
      };
      case (?find) {
        find.amount := amount;
        switch(remark){
          case (null) {
            
          };
          case (?remark) {
            find.remark := ?remark;
          };
        };
        return {
          code=1;
          msg="未找到记录 id = " # Nat.toText(id);
        };
      };
    }
  };

  public shared func receiveVftLogs(body:[VftLogParam],sign:Text): async Result  {
      try{
          var sign_array :[Text]= [];
          let ids = Buffer.Buffer<Nat>(10);
          for (item in body.vals()){
            // uid,amount,customer_id,source_id,source_code,order_no,uid,amount.....
            sign_array :=  Array.append<Text>(sign_array,[Nat.toText(item.uid),Int.toText(item.amount),Nat.toText(item.customer_id),item.source_code,item.order_no,Nat.toText(item.create_time)]);
            ids.add(item.token_apply_id);
          };
          ignore LOGGER.log(#INFO,"token_apply_id",debug_show("签名出错"));
          let check = SignUtil.check_sign(sign_array,sign,Config.SECRET_KEY);
          if(not check){
            //ignore LOGGER.log(#ERROR,"receiveVftLogs-error",debug_show("receiveVftLogs 错误 log=",Error.message(error)));
            return {
              code=501;
              msg="签名错误";
            };
          };
          for (item in body.vals()){
              let buffer = Buffer.Buffer<Text>(10); // Creates a new Buffer
              let res = VftTypes.dealVftLog(item,userTableMap,tokenPlanTaskTable,buffer);
              ignore LOGGER.log(#INFO,"receiveVftLogs",debug_show("receiveVftLogs 计算vft过程 log=",Buffer.toText(buffer, func (x : Text) : Text { x })));
              assert res.code == 200;
          };
          {
                code=200;
                msg="处理成功";
          }
      }catch(error:Error){
          ignore LOGGER.log(#ERROR,"receiveVftLogs-error",debug_show("receiveVftLogs 错误 log=",Error.message(error)));
          return {
              code=500;
              msg=Error.message(error);
          };
      }
  };

  public query func totalCount(): async Nat {
    var total =0;
    let emptySet = Set.Make<VftLog>(VftTypes.compareVftLog);
    for (item in userTableMap.vals()){
      total := total + emptySet.size(item.vft_logs);
    };
    total;
  };
  public query func test_show_user(uid:Nat): async ?{
    logs : [VftLog];
    amount : Int;
  }  {
      let user= userTableMap.get(uid);
        switch(user){
            case (null) {
                return null;
            };
            case (?user) {
              ?{
                logs = VftTypes.setToArray(user.vft_logs);
                amount = user.vft_balance;
              }
            };
        }
  };

  public query func queryVftLogs(uid:Nat,start:Nat,end:Nat,sign:Text): async [VftLog]  {
      try{
        let check = SignUtil.check_sign([Nat.toText(uid),Nat.toText(start),Nat.toText(end)],sign,Config.SECRET_FRONTEND);
        if(not check){
          throw Error.reject("签名错误");
        };
        // check sign
        let user= userTableMap.get(uid);
        switch(user){
            case (null) {
                return [];
            };
            case (?user) {
                Array.filter(VftTypes.setToArray(user.vft_logs),func(item:VftLog):Bool{item.create_time >= start and item.create_time <= end});
            };
        }
      }catch(error:Error){
          throw Error.reject(Error.message(error));
      }
  };
  public shared func testCleanLog(uid:Nat): async Text  {
      try{
        if(uid ==0){
          userTableMap :=HashMap.HashMap<Nat,User>(1000, Nat.equal, Hash.hash);
          return "清理成功";
        };
        let user= userTableMap.get(uid);
        switch(user){
            case (null) {
                return "没找到到用户";
            };
            case (?user) {
                user.vft_logs := Set.Make<VftLog>(VftTypes.compareVftLog).empty();
                user.vft_balance := 0;
                return "清理成功";
            };
        }
      }catch(error:Error){
          throw Error.reject(Error.message(error));
      }
  };

  public query func queryVftLogTime(uid:Nat,sign:Text): async [Text]  {
      try{
        let check = SignUtil.check_sign([Nat.toText(uid)],sign,Config.SECRET_FRONTEND);
        if(not check){
          throw Error.reject("签名错误");
        };
        // check sign
        let user= userTableMap.get(uid);
        switch(user){
            case (null) {
                return [];
            };
            case (?user) {
                let arr = VftTypes.setToArray(user.vft_logs);
                let natSet = Set.Make<Text>(Text.compare); // : Operations<Nat>
                var set : Set.Set<Text> = natSet.empty();
                for (item in arr.vals()){
                  set := natSet.put(set,time.getMonth(item.create_time));
                };
                Iter.toArray(natSet.vals(set));
            };
        }
      }catch(error:Error){
          throw Error.reject(Error.message(error));
      }
  };


  public shared ({caller}) func updateInternetIdentity(uid:Nat,pid:?Text,ic_account_id:?Text): async Result  {
      try{
        if(caller != Principal.fromText("r7inp-6aaaa-aaaaa-aaabq-cai")){
          return {
            code=501;
            msg="只允许内部调用";
          };
        };
        let user= userTableMap.get(uid);
        switch(user){
            case (null) {
                return {
                  code=501;
                  msg="未找到记录 uid = " # Nat.toText(uid);
                };
            };
            case (?user) {
                user.pid := pid;
                user.ic_account_id := ic_account_id;
                return {
                  code=200;
                  msg="处理成功";
                };
            };
        }
      }catch(error:Error){
          throw Error.reject(Error.message(error));
      }
  };




  stable var admin_users : List.List<Principal> = List.nil();


    // 获取管理员
  public shared ({ caller }) func get_admin_users() : async List.List<Principal> {
      if(not isAdmin(caller)){
        throw Error.reject("You are not an administrator and cannot execute this function");
      };
      admin_users
  };
     // 增加管理员
  public shared ({ caller }) func add_admin_user(user: Principal) : async () {
      if(not Principal.isController(caller)){
        throw Error.reject("You are not an administrator and cannot execute this function");
      };
      let admin = List.find<Principal>(admin_users, func (v) {Principal.toText(v) == Principal.toText(user)});
      if(admin == null){
        admin_users := List.push(user, admin_users);
      };
  };

  // 删除管理员
  public shared ({ caller }) func delete_admin_user(user: Principal) : async () {
      if(not Principal.isController(caller)){
        throw Error.reject("You are not an administrator and cannot execute this function");
      };
      admin_users := List.filter<Principal>(admin_users, func (v) {Principal.toText(v) != Principal.toText(user)});
  };

  // 判断是否是管理员
  private func isAdmin(user: Principal): Bool{
  let admin = List.find<Principal>(admin_users, func (v) {Principal.toText(v) == Principal.toText(user)});
    if(admin != null or Principal.isController(user)) {
        return true;
    } else {
        return false;
    };
  };




  system func preupgrade() {
    icp_transaction_second_entries := Iter.toArray(icp_transaction_second_logs.entries());
    userTable := Iter.toArray(userTableMap.vals());
  };

  system func postupgrade() {
    icp_transaction_second_logs := HashMap.fromIter<Text, List.List<IcpTransactionSecondLogs>>(
      Iter.fromArray<(Text, List.List<IcpTransactionSecondLogs>)>(icp_transaction_second_entries),
      Array.size(icp_transaction_second_entries),Text.equal,Text.hash);
    icp_transaction_second_entries := [];
    userTableMap := HashMap.fromIter<Nat, User>(
      Iter.fromArray(Array.map<User, (Nat, User)>(userTable,func (item:User):(Nat, User) { return (item.uid, item) })),
      Array.size(userTable),
      Nat.equal,
      Hash.hash
    );
    userTable := [];
  };

};
