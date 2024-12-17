import List "mo:base/List";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import OrderedSet "mo:base/OrderedSet";
import Nat "mo:base/Nat";
import icp_rate "../../lib/icp_rate";
import VftTypes "VftTypes";

module {


    public type User = VftTypes.User;
    public type VftLog = VftTypes.VftLog;
    public type VfansInfo = {
        var vft_issue_toal_amount : Float; //vft发行总数
        var vft_destroy_toal_amount : Float; //vft销毁总数
        var exchange_VFT_amount : Float; //近24小时vft兑换总数
        var exchange_RMB_amount : Float; //近24小时rmb兑换总数
        var exchange_ICP_amount : Nat; //近24小时icp兑换总数
        var hold_ICP_account : List.List<Text>; //持有ICP的账号数量
        var exchang_total_count : Nat; //兑换总笔数
        var inventory_icp_amount : Nat; //库存ICP
        var exchang_total_ICP_amount : Nat; //总兑换icp数量 但是k8s
    };

    public type VfansInfoRead = {
        vft_issue_toal_amount : Int; //vft发行总数
        vft_destroy_toal_amount : Float; //vft销毁总数
        exchange_VFT_amount : Float; //vft兑换总数
        exchange_RMB_amount : Float; //rmb兑换总数
        exchange_ICP_amount : Float; //icp兑换总数
        hold_ICP_account_count : Nat; //持有ICP的账号数量
        exchang_total_count : Nat; //兑换总笔数
        inventory_icp_amount : Nat; //库存ICP
        enable_exchange_vft_amount : Float; //库存VFT
    };

    // public func getIssueToalAmount(userTable:HashMap.HashMap<Nat,User>) : Float{
    //     var vft_issue_toal_amount:Int = 0;
    //     var vft_destroy_toal_amount :Int = 0;
    //     var exchange_VFT_amount : Int = 0;
    //     // var exchange_RMB_amount :Int = 0;
    //     // var exchange_ICP_amount : Nat = 0;
    //     var exchang_total_count : Nat = 0;
    //     let myset = OrderedSet.Make<VftLog>(VftTypes.compareVftLog);
    //     for (info in userTable.vals()){
    //         vft_issue_toal_amount += info.vft_balance;
    //         let logs = info.vft_logs;
    //         for (log in myset.vals(logs)){
    //             // 14 ic  15 rmb
    //             if(log.source_id == 14){
    //                 vft_destroy_toal_amount += log.amount;
    //             }else if (log.source_id == 15){

    //             }
    //         };
    //     };

    //     0.0;
    // };


    public func calculateVfansInfo(logs:[VftTransactionLog],userTable:HashMap.HashMap<Nat,User>):{
        vft_issue_toal_amount :Int;
        vft_destroy_toal_amount :Float;
        exchange_VFT_amount : Float;
        exchange_RMB_amount :Float;
        exchange_ICP_amount : Float;
        exchang_total_count : Nat;
        hold_ICP_account : Nat;
    }{
        var vft_issue_toal_amount:Int = 0;
        var vft_destroy_toal_amount :Float = 0;
        var exchange_VFT_amount : Float = 0;
        var exchange_RMB_amount :Float = 0;
        var exchange_ICP_amount : Float = 0;
        var exchang_total_count : Nat = 0;
        // var hold_ICP_account : Nat = 0;
        for (info in userTable.vals()){
            vft_issue_toal_amount += info.vft_balance;
        };
        let textSet = OrderedSet.Make<Text>(Text.compare);
        var set : OrderedSet.Set<Text> = textSet.empty();
        //hold_ICP_account
        for(log in logs.vals()){
            if(log.log_type == #withdrawal_icp or log.log_type == #withdrawal_rmb){
                vft_destroy_toal_amount += log.log_vft_count;
                exchange_VFT_amount += log.log_vft_count;
                exchang_total_count += 1;
                set:=textSet.put(set,log.from);
                if(log.log_type == #withdrawal_icp){
                    exchange_ICP_amount += log.log_amount;
                }else if (log.log_type == #withdrawal_rmb){
                    exchange_RMB_amount += log.log_amount;
                };
            };
        };
        return {
            vft_issue_toal_amount = vft_issue_toal_amount;
            vft_destroy_toal_amount = vft_destroy_toal_amount;
            exchange_VFT_amount = exchange_VFT_amount;
            exchange_RMB_amount = exchange_RMB_amount;
            exchange_ICP_amount = exchange_ICP_amount;
            exchang_total_count = exchang_total_count;
            hold_ICP_account = textSet.size(set);
        };
    };

    public type Tokens = {
        e8s : Nat64;
    };

    public type TransferArgs = {
        amount : Tokens;
        accountId : Blob;
    };

    public type ProxyTransferArgs = {
        sign : Text;
        toPrincipal : Text;
        fromPrincipal : Text;
        vftCount : Float;
        time : Nat;
        // 0 icp 1 rmb
        transfer_money_type : Nat;
        nickname : Text;
    };

    public type Account = {
        owner : Principal;
        subaccount : ?Blob;
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
    public type Rate = {
        var rate : Float;
        var yesterday_rate : Float;
        var update_time : Int;
        currency_type : icp_rate.Asset;
    };
    public type RateRecord = {
        rate : Float;
        yesterday_rate : Float;
        update_time : Int;
        currency_type : icp_rate.Asset;
    };
    public type IcpTransactionSecondLogs = {
        //日志ID
        amount : Nat;
        // 事务类型
        to : Text;
        // 交易时间
        txId : Int;
        // 交易金额
        time : Int64;
    };

    public type VftTransactionLogs = List.List<VftTransactionLog>;

    //事务日志
    public type VftTransactionLog = {

        // from 
        from : Text;
        // to 
        to : Text;
        // nickName
        nickname : Text;
        // chainId
        chain_id : Nat;
        //日志ID
        log_id : Nat;
        // 事务类型
        log_type : VftTransactionLogType;
        // 交易时间
        log_time : Int;
        // 交易金额
        log_amount : Float;
        // vft 数量
        log_vft_count : Float;


    };
    //事务日志类型  兑换ICP 兑换RMB 提取到三方钱包
    public type VftTransactionLogType = {#withdrawal_icp;#withdrawal_rmb;#register};




};
