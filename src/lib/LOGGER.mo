// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
    public type LOG_TYPE = { #INFO; #WARN; #DEBUG; #FATAL; #TRACE; #ERROR };
    public type Log = {
        custom_type : Text;
        time : Int;
        message : Text;
        log_level : LOG_TYPE;
    };
    public type Result = { code : Nat; message : Text };
    public type Self = actor {
        getLogs : shared query Principal -> async [Log];
        log : shared (LOG_TYPE, Text, Text) -> async Result;
        register : shared () -> async Nat;
    };
};
