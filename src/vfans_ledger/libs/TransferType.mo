import List "mo:base/List";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Float "mo:base/Float";
import Int "mo:base/Int";
import icp_rate "../../lib/icp_rate";
module {

    public type VfansInfo = {
        var vft_issue_toal_amount : Float; //vft发行总数
        var vft_destyoy_toal_amount : Float; //vft销毁总数
        var exchange_VFT_amount : Float; //近24小时vft兑换总数
        var exchange_RMB_amount : Float; //近24小时rmb兑换总数
        var exchange_ICP_amount : Nat; //近24小时icp兑换总数
        var hold_ICP_account : List.List<Text>; //持有ICP的账号数量
        var exchang_total_count : Nat; //兑换总笔数
        var inventory_icp_amount : Nat; //库存ICP
        var exchang_total_ICP_amount : Nat; //总兑换icp数量 但是k8s
    };

    public type VfansInfoRead = {
        vft_issue_toal_amount : Float; //vft发行总数
        vft_destyoy_toal_amount : Float; //vft销毁总数
        exchange_VFT_amount : Float; //近24小时vft兑换总数
        exchange_RMB_amount : Float; //近24小时rmb兑换总数
        exchange_ICP_amount : Nat; //近24小时icp兑换总数
        hold_ICP_account_count : Nat; //持有ICP的账号数量
        exchang_total_count : Nat; //兑换总笔数
        inventory_icp_amount : Nat; //库存ICP
        exchang_total_ICP_amount : Nat; //总兑换icp数量 
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
