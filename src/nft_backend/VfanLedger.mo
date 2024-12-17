// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
    public type Asset = { class_ : AssetClass; symbol : Text };
    public type AssetClass = { #Cryptocurrency; #FiatCurrency };
    public type CanisterHttpResponsePayload = {
        status : Nat;
        body : Blob;
        headers : [HttpHeader];
    };
    public type HttpHeader = { value : Text; name : Text };
    public type HttpResponsePayload = {
        status : Nat;
        body : Blob;
        headers : [HttpHeader];
    };
    public type IcpTransactionSecondLogs = {
        to : Text;
        time : Int64;
        txId : Int;
        amount : Nat;
    };
    public type List = ?(Log, List);
    public type List_1 = ?(IcpTransactionSecondLogs, List_1);
    public type Log = {
        content : Text;
        time : Int;
        log_type : LogType;
        log_id : Int;
    };
    public type LogSet = ?(Log, List);
    public type LogType = { #query_icp_rate; #simple; #query_icp_usd_rate };
    public type ProxyTransferArgs = {
        nickname : Text;
        vftCount : Float;
        sign : Text;
        time : Nat;
        toPrincipal : Text;
        transfer_money_type : Nat;
        fromPrincipal : Text;
    };
    public type RateRecord = {
        rate : Float;
        currency_type : Asset;
        update_time : Int;
        yesterday_rate : Float;
    };
    public type Result = { msg : Text; code : Nat };
    public type Result__1 = { #ok : Nat; #err : Text };
    public type Result__1_1 = { #ok : Nat64; #err : Text };
    public type TokenPlanTaskView = {
        id : Nat;
        remark : ?Text;
        code : Text;
        name : Text;
        create_by : ?Text;
        update_time : ?Nat;
        update_by : ?Text;
        create_time : ?Nat;
        amount : Int;
    };
    public type Tokens = { e8s : Nat64 };
    public type TransferArgs = { accountId : Blob; amount : Tokens };
    public type TransformArgs = {
        context : Blob;
        response : HttpResponsePayload;
    };
    public type VfansInfoRead = {
        exchange_RMB_amount : Float;
        exchange_ICP_amount : Nat;
        vft_destyoy_toal_amount : Float;
        exchange_VFT_amount : Float;
        inventory_icp_amount : Nat;
        exchang_total_count : Nat;
        hold_ICP_account_count : Nat;
        exchang_total_ICP_amount : Nat;
        vft_issue_toal_amount : Float;
    };
    public type VftLog = {
        remark : Text;
        log_id : Nat;
        source_id : Nat;
        customer_id : Nat;
        source_code : Text;
        create_time : Nat;
        order_no : Text;
        token_apply_id : Nat;
        amount : Int;
    };
    public type VftLogParam = {
        uid : Nat;
        remark : Text;
        sign : Text;
        log_id : Nat;
        source_id : Nat;
        customer_id : Nat;
        source_code : Text;
        create_time : Nat;
        order_no : Text;
        token_apply_id : Nat;
        amount : Int;
    };
    public type VftTransactionLog = {
        to : Text;
        nickname : Text;
        from : Text;
        log_vft_count : Float;
        log_time : Int;
        log_type : VftTransactionLogType;
        log_id : Nat;
        chain_id : Nat;
        log_amount : Float;
    };
    public type VftTransactionLogType = {
        #withdrawal_icp;
        #withdrawal_rmb;
        #register;
    };
    public type tokens = { e8s : Nat64 };
    public type Self = actor {
        add_icp_transaction_second_log : shared IcpTransactionSecondLogs -> async Text;
        do_get_exchange_rate : shared (Asset, Bool) -> async RateRecord;
        getTokenPlanTaskTable : shared query () -> async [TokenPlanTaskView];
        get_address : shared () -> async Text;
        get_exchange_rate : shared (Asset, Bool) -> async RateRecord;
        get_exchange_rate_rmb : shared Bool -> async RateRecord;
        get_exchange_rate_usd : shared Bool -> async RateRecord;
        get_icp_transaction_second_log : shared query Text -> async [
            IcpTransactionSecondLogs
        ];
        get_icp_transaction_second_log2 : shared query () -> async [(Text, List_1)];
        get_log : shared () -> async LogSet;
        init_exchang_total_count : shared Nat -> async Nat;
        init_inventory_icp_amount : shared () -> async Nat;
        proxy_transfer : shared ProxyTransferArgs -> async Result__1;
        queryICP : shared Text -> async tokens;
        queryVfanInfo : shared () -> async VfansInfoRead;
        queryVftLogTime : shared query (Nat, Text) -> async [Text];
        queryVftLogs : shared query (Nat, Nat, Nat, Text) -> async [VftLog];
        query_balance : shared query () -> async Nat;
        query_sin_str : shared ProxyTransferArgs -> async Text;
        receiveVftLogs : shared ([VftLogParam], Text) -> async Result;
        show_vft_transaction_log : shared query () -> async [VftTransactionLog];
        transfer : shared TransferArgs -> async Result__1_1;
        transfer_rmb : shared ProxyTransferArgs -> async Result__1;
        transform : shared query TransformArgs -> async CanisterHttpResponsePayload;
        updateInternetIdentity : shared (Nat, ?Text, ?Text) -> async Result;
        updateTokenPlanTaskTable : shared (Nat, Int, ?Text, Text) -> async Result;
    };
};
