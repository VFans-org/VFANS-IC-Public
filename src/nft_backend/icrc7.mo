import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Types "./Types";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Hex "../lib/Hex";
import Config "../lib/Config";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Int "mo:base/Int";
import HttpTypes "HttpTypes";
import Sha256 "SHA256";
import Cycles "mo:base/ExperimentalCycles";
import Json "json";
import { setTimer; recurringTimer; cancelTimer } = "mo:base/Timer";
import Error "mo:base/Error";
import IC "mo:base/ExperimentalInternetComputer";
import Result "mo:base/Result";
import icp_ledger_canister "../lib/icp_ledger_canister";
import NumberUtil "../lib/NumberUtil";
import VfanLedger "VfanLedger";
import LOGGER_ "../lib/LOGGER";


shared actor class ICRC7NFT(env : Text) = Self {

  type icp_ledger_canister_ = icp_ledger_canister.Self;

  let icp_ledger_canister_holder : icp_ledger_canister_ = actor (Config.ICP_LEDGER_CANISTER_ID);
  let vfans_ledger_canister : VfanLedger.Self = actor (Config.VFANS_LEDGER_CANISTER_ID);
  let LOGGER : LOGGER_.Self = actor(Config.LOGGER_SERVICE_CANISTER_ID);

  // var timerId : Nat = 1;
  // var fiveSecond = 5;
  // var fiftySecond = 50;
  // let daySeconds = 24 * 60 * 60;
  var stop_flag = false;
  // var timeLock = false;

  type ErrorLog = {
    error_time : Int;
    error_msg : Text;
    error_type : Text;
  };
  type CyclesBalance = {
    create_time : Int;
    balance : Nat;
  };
  type blob = Blob;
  type principal = Principal;
  type nat = Nat;
  type nat64 = Nat64;

  type Account = {
    owner : principal;
    subaccount : ?blob;
  };
  public type ApproveArgs = {
    fee : ?Nat;
    memo : ?Blob;
    from_subaccount : ?Blob;
    created_at_time : ?Nat64;
    amount : Nat;
    expected_allowance : ?Nat;
    expires_at : ?Nat64;
    spender : Account;
  };

  stable var error_list = List.nil<ErrorLog>();
  stable var cycles_ledger = List.nil<CyclesBalance>();

  stable var update_list = List.nil<Text>();
  // type ListType = List.List<Types.Nft>;
  //       初始事务ID
  stable var transactionId : Types.TransactionId = 0;
  // 初始 nft货币值为空
  stable var nfts = List.nil<Types.Nft>();
  stable var nfts_list = List.nil<Types.NftNew>();
  // 初始化 custodians 数组
  // 数组中存放的元素是 Principal
  // stable var custodians = List.make<Principal>(custodian);
  // 初始化 logo 图片
  stable var logo : Types.LogoResult = { data = "xxx"; logo_type = "xxx" };
  // 初始化 name 名称
  stable var name : Text = "nft";
  stable var symbol : Text = "icrc7";

  // 初始化 最大发行量
  // stable var maxLimit : Nat16 = 9_999;
  // 创建一个新的主体 aaaaa-aa
  // let null_address : Principal = Principal.fromText("aaaaa-aa");

  var update_index = 0;
  var update_size = 1000;
  type VFTParams = {
    sbt_card_image : Text;
    sbt_membership_category : Text;
    sbt_get_time : Text;
    vft_count : Text;
    vft_info : Text;
    user_id : Text;
    sbt_card_number : Text;
    ic_account_id : Text;
    reputation_point : Text;
    // transferable : Text;
    // mint_time : Text;
  };

  //授权
  public shared ({ caller }) func approve(amount : Nat, principal : Text) : async Result.Result<Nat, Text> {
    let args : ApproveArgs = {
      fee = null;
      memo = null;
      from_subaccount = null;
      created_at_time = null;
      expected_allowance = null;
      expires_at = null;
      amount = amount;
      spender = { owner = Principal.fromText(principal); subaccount = null };
    };
    try {
      // initiate the transfer
      let transferResult = await icp_ledger_canister_holder.icrc2_approve(args);

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
    return #err("Couldn't transfer funds:\n 未知错误");
  };

  // public func query_one_time() : async Text {
  //   try {
  //     //构建body
  //     let body = build_query_body();
  //     if (Text.size(body) == 0) {
  //       return "未查询到NFT不进行更新操作";
  //     };
  //     //发送http 请求
  //     let https_resp = await do_send_post(body, "sbt-info");
  //     // Debug.print(debug_show ("返回结果" #https_resp));
  //     //处理返回结果
  //     let result = deal_https_resp(https_resp, "update");
  //     if (result != "处理成功") {
  //       return result;
  //     };
  //   } catch e {
  //     let err_msg : Text = show_error(e);
  //     let aaa : ErrorLog = {
  //       error_time = Time.now();
  //       error_msg = err_msg;
  //       error_type = "更新NFT 出错";
  //     };
  //     error_list := List.push(aaa, error_list);
  //     return "处理失败";
  //   };
  //   "处理成功";
  // };
  // public func test_query_one_time() : async Text {
  //   try {
  //     //构建body
  //     let body = test_build_query_body();
  //     Debug.print("--------" # body);
  //     //发送http 请求
  //     let https_resp = await do_send_post(body, "sbt-info");
  //     return https_resp;
  //   } catch e {
  //     let err_msg : Text = show_error(e);
  //     let aaa : ErrorLog = {
  //       error_time = Time.now();
  //       error_msg = err_msg;
  //       error_type = "更新NFT 出错";
  //     };
  //     error_list := List.push(aaa, error_list);
  //     return "处理失败";
  //   };
  // };

  var update_flag = false;
  public shared func update_nfts(data:[{ic_account_id:Text;uid:Nat}]) : async Text {
      if(update_flag){
        return "已更新完成";
      };
      var updateCount =0;
      for (item in data.vals()) {
        let find = List.find(nfts_list, func(token : Types.NftNew) : Bool { token.owner == item.ic_account_id });
        switch(find){
          case (null){
            //
          };
          case (?find){
            find.uid := ?item.uid;
            nfts_list :=List.push<Types.NftNew>(find,nfts_list);
            updateCount +=1;
          }
        }
      };
      update_flag := true;
      "处理成功跟新NFT数量" # Nat.toText(updateCount);
  };

  func show_error(err : Error) : Text {
    debug_show ({ error = Error.code(err); message = Error.message(err) });
  };

  public shared func deal_https_resp_test(resp : Text, ic_account_id : Text) : async Text {
    let nft = List.find(nfts_list, func(token : Types.NftNew) : Bool { token.owner == ic_account_id });
    switch (nft) {
      case (null) {
        return "没查到";
      };
      case (?nft) {
        return await queryNfts(ic_account_id);
      };
    };
  };

  func getNft(uid:Nat):?Types.NftNew{
    List.find(nfts_list, func(token : Types.NftNew) : Bool { 
      switch (token.uid) {
        case (?token_id) {
          return token_id == uid;
        };
        case(null){
            false;
        }
      };
    });
  };

  public query func getUpdate(op : Nat) : async Text {
    if (op == 1) {
      update_list := List.nil<Text>();
    };
    return debug_show (update_list);
  };

  func deal_https_resp(uid:Nat,resp : Text, op : Text) : Text {
    Debug.print(debug_show("method","deal_https_resp","uid",uid,"resp",resp,"op",op));
    let split_array = Text.split(resp, #char ';');
    let status_code = Option.get(split_array.next(), "0");
    if (status_code != "200") {
      return resp;
    };
    for (message in split_array) {
      let message_line = Iter.toArray(Text.split(message, #char ','));
      // let uid=message_line[0];
      let sbt_card_image = message_line[1];
      let sbt_category = message_line[2];
      let sbt_get_time = message_line[3];
      let vft_count = message_line[4];
      let sbt_card_number = message_line[5];
      let ic_account_id = message_line[6];
      let reputation_point = message_line[7];
      let nft = List.find(nfts_list, func(token : Types.NftNew) : Bool { Option.get(token.uid,9999999999999999) == uid });

      switch (nft) {
        case (null) {
          if (op == "bind") {
            let vft_params : VFTParams = {
              sbt_card_image = sbt_card_image;
              sbt_membership_category = sbt_category;
              sbt_get_time = sbt_get_time;
              vft_count = vft_count;
              vft_info = "";
              user_id = message_line[0];
              sbt_card_number = sbt_card_number;
              ic_account_id = ic_account_id;
              reputation_point = reputation_point;
            };
            ignore mintICRC7(vft_params,uid);

          }else {
            let aaa : ErrorLog = {
              error_time = Time.now();
              error_msg = ic_account_id # "未查询NFT信息";
              error_type = "更新出错，未查询到NFT信息";
            };
            error_list := List.push(aaa, error_list);
          };
        };
        case (?nft) {
          if(op == "update" or op == "bind"){
            if(op == "bind"){
              nft.owner := ic_account_id;
            };
            update_list := List.push(ic_account_id, update_list);
            //更新sbt照片
            nft.meta[0].key_val_data[0] := {
              key = "sbt_card_image";
              val = #TextContent(sbt_card_image);
            };
            //创世卡类型
            let old_sbt = getText(nft.meta[0].key_val_data[1].val);
            if (Types.getSBTCardLevel(old_sbt) < Types.getSBTCardLevel(sbt_category)) {
              nft.meta[0].key_val_data[1] := {
                key = "sbt_membership_category";
                val = #TextContent(sbt_category);
              };
            };

            //第一笔充值时间
            nft.meta[0].key_val_data[2] := {
              key = "sbt_get_time";
              val = #TextContent(sbt_get_time);
            };
            //vft数量
            nft.meta[0].key_val_data[3] := {
              key = "vft_count";
              val = #TextContent(vft_count);
            };
            // 4 vft Info 暂不处理
            //更新时间
            nft.meta[0].key_val_data[5] := {
              key = "vft_update_time";
              val = #IntContent(Time.now());
            };
            //user 不更新
            //卡号
            nft.meta[0].key_val_data[7] := {
              key = "sbt_card_number";
              val = #TextContent(sbt_card_number);
            };
            //IC account ID
            nft.meta[0].key_val_data[8] := {
              key = "ic_account_id";
              val = #TextContent(ic_account_id);
            };
            //声誉值
            nft.meta[0].key_val_data[9] := {
              key = "reputation_point";
              val = #TextContent(reputation_point);
            };
          }else if(op=="unbind"){
            nft.owner := "";
            nft.meta[0].key_val_data[8] := {
              key = "ic_account_id";
              val = #TextContent("");
            };
          }
        }
      };
    };
    return "处理成功";
  };

  func build_binding_body(user_id : Text, ic_account_id : Text, ic_principle_id : Text, op : Text) : Text {
    let body = user_id # "," #ic_account_id # "," # ic_principle_id # "," # op;
    let signStr = body # Config.SECRET;
    let sign = Sha256.sha256_with_text(signStr);
    return "{\"user_id\":\"" # user_id # "\",\"ic_account_id\":\"" # ic_account_id #"\",\"ic_principle_id\":\"" # ic_principle_id # "\",\"op\":\"" # op # "\"" # ",\"sign\":\"" #debug_show (sign) # "\"}";
  };
  // func build_query_body() : Text {
  //   //{
  //   //"ic_account_id_list":
  //   //  "AAAAA,"
  //   //}
  //   let list = get_nft_owner_list();
  //   // Debug.print(debug_show ("list=" # list));
  //   if (Text.size(list) == 0) {
  //     return "";
  //   };
  //   let signStr = list # Config.SECRET;
  //   let sign = Sha256.sha256_with_text(signStr);

  //   return "{\"ic_account_id_list\":\"" # list # "\"" # ",\"sign\":\"" #debug_show (sign) # "\"}"

  // };


  //查询固定数量的NFT ，每次查询指针后移
  func get_nft_owner_list() : Text {
    var sub = "";
    label loop2 for (i in Iter.range(1, update_size)) {
      // Debug.print(debug_show ("update_index2"));
      // Debug.print(debug_show (update_index));
      let update : ?Types.NftNew = List.get(nfts_list, update_index);
      // Debug.print(debug_show (update_index));
      // Debug.print(debug_show (update));
      update_index := update_index +1;
      switch (update) {
        case (null) {
          //查询完最后以后指针自动跳回起始点
          update_index := 0;
          stop_flag := true;
          break loop2;
        };
        case (?update) {
          sub := sub # update.owner # ",";
        };
      };
    };
    Debug.print(debug_show (debug_show (update_index) # "------------------" # sub));
    sub;
  };
  public query func nft_count() : async Nat {
    List.size(nfts_list);
  };

  public query func queryNfts(ic_account_id : Text) : async Text {
    let nft = List.find(nfts_list, func(token : Types.NftNew) : Bool { token.owner == ic_account_id });
    switch (nft) {
      case (null) {
        "-1";
      };
      case (?nft) {
        let sbt_card_image = getText(nft.meta[0].key_val_data[0].val);
        let sbt_membership_category = getText(nft.meta[0].key_val_data[1].val);
        let sbt_get_time = getText(nft.meta[0].key_val_data[2].val);
        let vft_count = getText(nft.meta[0].key_val_data[3].val);
        let vft_update_time = getText(nft.meta[0].key_val_data[5].val);
        let sbt_card_number = getText(nft.meta[0].key_val_data[7].val);
        let ic_account_id = getText(nft.meta[0].key_val_data[8].val);
        let reputation_point = getText(nft.meta[0].key_val_data[9].val);
        let mint_time = getText(nft.meta[0].key_val_data[11].val);
        let uid = switch(nft.uid){case (?uid) { Nat.toText(uid);};case (null) {""}};
        var result : Text = "";
        result := Json.addJson(null, "sbt_card_image", sbt_card_image);
        result := Json.addJson(?result, "sbt_membership_category", sbt_membership_category);
        result := Json.addJson(?result, "sbt_get_time", sbt_get_time);
        result := Json.addJson(?result, "vft_update_time", vft_update_time);
        result := Json.addJson(?result, "vft_count", vft_count);
        result := Json.addJson(?result, "sbt_card_number", sbt_card_number);
        result := Json.addJson(?result, "ic_account_id", ic_account_id);
        result := Json.addJson(?result, "reputation_point", reputation_point);
        result := Json.addJson(?result, "owner", nft.owner);
        result := Json.addJson(?result, "vfans_account_id", Config.VFANS_ACCOUNT_ID);
        result := Json.addJson(?result, "nft_type", "ICRC7");
        result := Json.addJson(?result, "location", "Internet Computer");
        result := Json.addJson(?result, "mint_time", mint_time);
        result := Json.addJson(?result, "uid",uid);
        return Json.toJsonStr(result);
      };
    };
  };
  public query func queryNfts2(index : Nat) : async Text {
    let nft = List.get(nfts_list, index);
    switch (nft) {
      case (null) {
        "-1";
      };
      case (?nft) {
        let sbt_card_image = getText(nft.meta[0].key_val_data[0].val);
        let sbt_membership_category = getText(nft.meta[0].key_val_data[1].val);
        let sbt_get_time = getText(nft.meta[0].key_val_data[2].val);
        let vft_count = getText(nft.meta[0].key_val_data[3].val);
        let vft_update_time = getText(nft.meta[0].key_val_data[5].val);
        let sbt_card_number = getText(nft.meta[0].key_val_data[7].val);
        let ic_account_id = getText(nft.meta[0].key_val_data[8].val);
        let reputation_point = getText(nft.meta[0].key_val_data[9].val);
        let mint_time = getText(nft.meta[0].key_val_data[11].val);
        var result : Text = "";
        result := Json.addJson(null, "sbt_card_image", sbt_card_image);
        result := Json.addJson(?result, "sbt_membership_category", sbt_membership_category);
        result := Json.addJson(?result, "sbt_get_time", sbt_get_time);
        result := Json.addJson(?result, "vft_update_time", vft_update_time);
        result := Json.addJson(?result, "vft_count", vft_count);
        result := Json.addJson(?result, "sbt_card_number", sbt_card_number);
        result := Json.addJson(?result, "ic_account_id", ic_account_id);
        result := Json.addJson(?result, "reputation_point", reputation_point);
        result := Json.addJson(?result, "owner", nft.owner);
        result := Json.addJson(?result, "vfans_account_id", Config.VFANS_ACCOUNT_ID);
        result := Json.addJson(?result, "nft_type", "ICRC7");
        result := Json.addJson(?result, "location", "Internet Computer");
        result := Json.addJson(?result, "mint_time", mint_time);
        return Json.toJsonStr(result);
      };
    };
  };

  func getText(input : Types.MetadataVal) : Text {
    switch (input) {
      case (#TextContent(text)) {
        return text;
      };
      case (#IntContent(text)) {
        return Int.toText(text);
      };
      case _ {
        return "未知类型";
      };
    };
  };
  public func get_version() : async Text {
    return "1.0.5";
  };

  public shared func clean() : async () {
    nfts_list := List.nil<Types.NftNew>();
  };

  //绑定并铸币
  public shared func binding_vfans(user_id : Text, ic_account_id : Text, ic_principle_id : Text,op:Text) : async Text {
    try {
      Debug.print("接收请求user_id=" #user_id # ",ic_account_id=" #ic_account_id # ",ic_principle_id=" # ic_principle_id # ",op" # op);
      //构建body
      let body = build_binding_body(user_id, ic_account_id, ic_principle_id, op);
      Debug.print(debug_show ("请求内容" #body));
      //发送http 请求
      let https_resp = await do_send_post(body, "icAccount");
      Debug.print(debug_show ("返回结果" #https_resp));
      //处理返回结果
      let result = deal_https_resp(NumberUtil.textToNat(user_id),https_resp, op);
      if (result != "处理成功") {
        // uid pid ic_account_id
        let res = await vfans_ledger_canister.updateInternetIdentity(NumberUtil.textToNat(user_id),?ic_principle_id,?ic_account_id);
        ignore LOGGER.log(#ERROR,"updateInternetIdentity-result",debug_show ("更新用户信息返回结果" , res));
        return result;
      };
    } catch e {
      Debug.print(show_error(e));
      let err_msg : Text = show_error(e);
      let aaa : ErrorLog = {
        error_time = Time.now();
        error_msg = err_msg;
        error_type = "绑定出错";
      };
      error_list := List.push(aaa, error_list);
      let body = build_binding_body(user_id, ic_account_id,ic_principle_id, "unbind");
      Debug.print(debug_show ("请求内容" #body));
      //发送http 请求
      let https_resp = await do_send_post(body, "icAccount");
      Debug.print(debug_show ("返回结果" #https_resp));
      return "处理失败";
    };
    "处理成功";
  };

  public shared ({ caller }) func whoami() : async Principal {
    return caller;
  };

  public shared ({ caller }) func getIcAccountId() : async Text {
    return Hex.encode(Blob.toArray(Principal.toLedgerAccount(caller, null)));
  };

  func mintICRC7(VFT : VFTParams,uid:Nat) : Text {
    let now : Int = Time.now();
    // let STBCardImage = Blob.fromArray([97, 98, 99]);
    let SBTGetTime : Nat32 = 1;
    let SBTMembershipCategory = "register";
    //reputationPoint
    let meat : Types.MetadataPart = {
      data = Blob.fromArray([97, 98, 99]);
      key_val_data : [var Types.MetadataKeyVal] = [
        var { key = "sbt_card_image"; val = #TextContent(VFT.sbt_card_image) },
        {
          key = "sbt_membership_category";
          val = #TextContent(VFT.sbt_membership_category);
        },
        { key = "sbt_get_time"; val = #TextContent(VFT.sbt_get_time) },
        { key = "vft_count"; val = #TextContent(VFT.vft_count) },
        { key = "vft_info"; val = #TextContent(VFT.vft_info) },
        { key = "vft_update_time"; val = #IntContent(Time.now()) },
        { key = "user_id"; val = #TextContent(VFT.user_id) },
        { key = "sbt_card_number"; val = #TextContent(VFT.sbt_card_number) },
        { key = "ic_account_id"; val = #TextContent(VFT.ic_account_id) },
        { key = "reputation_point"; val = #TextContent(VFT.reputation_point) },
        { key = "transferable"; val = #TextContent("0") },
        { key = "mint_time"; val = #IntContent(Time.now()) },
      ];
      purpose : Types.MetadataPurpose = #Preview;
    };
    let metadataArray : [Types.MetadataPart] = [meat];
    let desc : Types.MetadataDesc = metadataArray;
    return realMintICRC7(VFT.ic_account_id, uid,desc);
  };

  func realMintICRC7(accountId : Text,uid:Nat, metadata : Types.MetadataDesc) : Text {
    let newId = Nat64.fromNat(List.size(nfts_list));
    let nft : Types.NftNew = {
      from = accountId;
      id = newId;
      meta = metadata;
      op = "7mint";
      var owner = accountId;
      var uid = ?uid;
      tid = transactionId;
      to = accountId;
    };
    nfts_list := List.push(nft, nfts_list);
    transactionId += 1;
    return "铸币成功";
  };



  // ========================http request==========================================================================================

  public query func show_env() : async Text {
    env;
  };
  public func do_send_post(body : Text, uri : Text) : async Text {

    // let url = "https://api-dev.vfans.org/user/sbt-info";
    var url = "https://api.vfans.org/user/" #uri;
    var host = "api.vfans.org";
    if (env == "test") {
      url := "https://api-dev.vfans.org/user/" #uri;
      host := "api-dev.vfans.org";
    };

    Cycles.add<system>(230_850_258_000);
    let ic : HttpTypes.IC = actor ("aaaaa-aa");
    let http_response : HttpTypes.HttpResponsePayload = await ic.http_request(get_http_req(body, url, host));
    let response_body : Blob = Blob.fromArray(http_response.body);
    let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    //6. RETURN RESPONSE OF THE BODY
    // let result : Text = decoded_text # ". See more info of the request sent at: " # url # "/inspect";
    let result : Text = decoded_text;
    result;
  };

  public func test_post(url : Text, host : Text) : async Text {
    Cycles.add<system>(230_850_258_000);
    let ic : HttpTypes.IC = actor ("aaaaa-aa");
    let http_response : HttpTypes.HttpResponsePayload = await ic.http_request(get_http_req("test", url, host));
    let response_body : Blob = Blob.fromArray(http_response.body);
    let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    //6. RETURN RESPONSE OF THE BODY
    // let result : Text = decoded_text # ". See more info of the request sent at: " # url # "/inspect";
    let result : Text = decoded_text;
    result;
  };

  func get_http_req(body : Text, url : Text, host : Text) : HttpTypes.HttpRequestArgs {
    let request_body_json : Text = body;
    let request_body_as_Blob : Blob = Text.encodeUtf8(request_body_json);
    let request_body_as_nat8 : [Nat8] = Blob.toArray(request_body_as_Blob);
    let transform_context : HttpTypes.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };
    return {
      url = url;
      max_response_bytes = null; //optional for request
      headers = get_http_header(host);
      //note: type of `body` is ?[Nat8] so we pass it here as "?request_body_as_nat8" instead of "request_body_as_nat8"
      body = ?request_body_as_nat8;
      method = #post;
      transform = ?transform_context;
    };
  };

  func get_http_header(host : Text) : [HttpTypes.HttpHeader] {
    return [
      { name = "Host"; value = host # ":443" },
      { name = "User-Agent"; value = "http_post_sample" },
      { name = "Content-Type"; value = "application/json" },
      { name = "Idempotency-Key"; value = "123456" },
      { name = "task"; value = "vft" },
    ];
  };

  // public shared func transfer_old_nft_count() : async Nat {
  //   for (nft in Iter.fromArray(List.toArray(nfts))) {
  //     //op : Text;
  //   // tid : Nat;
  //   // from : Text;
  //   // to : Text;
  //   // var owner : Text;
  //   // id : TokenId;
  //   // var uid : ?Nat;
  //   // meta : MetadataDesc;
  //     nfts_list :=List.push<Types.NftNew>({
  //         op = nft.op;
  //         tid = nft.tid;
  //         from = nft.from;
  //         to = nft.to;
  //         var owner = nft.owner;
  //         id = nft.id;
  //         var uid = null;
  //         meta = nft.meta;
  //     }, nfts_list);
  //   };
  //   return List.size(nfts);
  // };

  public query func transform(raw : HttpTypes.TransformArgs) : async HttpTypes.CanisterHttpResponsePayload {
    let transformed : HttpTypes.CanisterHttpResponsePayload = {
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

  //==========查询账簿======================================================================
  public query func query_cycles_ledger() : async Text {
    return debug_show (cycles_ledger);
  };
  public query func query_balance() : async Nat {
    return Cycles.balance();
  };

  //==========定时任务======================================================================
  // private func outCall() : async () {
  //   let start = Time.now();
  //   if (stop_flag) {
  //     Debug.print("今日更新完成，结束定时任务");
  //     cancelTimer(timerId);
  //     return;
  //   };
  //   if (timeLock) {
  //     Debug.print("上一周期任务未执行完成，放弃本次执行任务");
  //     return;
  //   };
  //   timeLock := true;

  //   let result = await query_one_time();
  //   if (result != "处理成功") {
  //     Debug.print("----------------------更新出错" #result);
  //     stop_flag := true;
  //   };
  //   timeLock := false;
  //   let end = Time.now();
  // };

  //查询异常
  public query func getErrorLog() : async Text {
    return debug_show (error_list);
  };

  // 重启定时服务
  // private func resetQuery() : async () {
  //   let balance = Cycles.balance();
  //   let aaa : CyclesBalance = {
  //     create_time = Time.now();
  //     balance = balance;
  //   };
  //   cycles_ledger := List.push(aaa, cycles_ledger);
  //   Debug.print("重新启动定时服务");
  //   stop_flag := false;
  //   timerId := recurringTimer<system>(#seconds fiftySecond, outCall);
  // };

  // timerId := recurringTimer<system>(#seconds fiftySecond, outCall);
  // let a : Nat = recurringTimer<system>(#seconds daySeconds, resetQuery);


};
