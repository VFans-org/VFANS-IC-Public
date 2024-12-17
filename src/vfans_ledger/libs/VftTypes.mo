import Int "mo:base/Int";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Set "mo:base/OrderedSet";
import Order "mo:base/Order";
import Bool "mo:base/Bool";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";

module {
    public type User = {
        var pid : ?Text;
        var ic_account_id : ?Text;
        var uid : Nat;
        var vft_balance : Int;
        var vft_logs : Set.Set<VftLog>;
    };



    public type Result = {
        code : Nat;
        msg : Text;
    };
    public type VftLog = {
        amount : Int;
        customer_id : Nat;
        source_id : Nat;
        source_code : Text;
        remark : Text;
        order_no : Text;
        create_time : Nat;
        token_apply_id : Nat;
    };
    public type VftLogParam = {
        uid : Nat;
        amount : Int;
        customer_id : Nat;
        source_id : Nat;
        source_code : Text;
        remark : Text;
        order_no : Text;
        create_time : Nat;
        token_apply_id : Nat;
    };

    public type TokenPlanTask = {
        id : Nat;
        var name : Text;
        var code : Text;
        var amount : Int;
        var create_by : ?Text;
        var create_time : ?Nat;
        var update_by : ?Text;
        var update_time : ?Nat;
        var remark : ?Text;
    };
    public type TokenPlanTaskView = {
        id : Nat;
        name : Text;
        code : Text;
        amount : Int;
        create_by : ?Text;
        create_time : ?Nat;
        update_by : ?Text;
        update_time : ?Nat;
        remark : ?Text;
    };

    public func getOrNewUer(param : VftLogParam, userTable : HashMap.HashMap<Nat, User>) : User {
        let find = userTable.get(param.uid);
        switch (find) {
            case null {
                let newUser = {
                    var pid : ?Text = null;
                    var ic_account_id : ?Text = null;
                    var uid = param.uid;
                    var vft_balance : Int = 0;
                    var vft_logs : Set.Set<VftLog> = Set.Make<VftLog>(compareVftLog).empty();
                };
                userTable.put(param.uid, newUser);

                return newUser;
            };
            case (?find) {
                return find;
            };
        };
    };

    public func compareVftLog(a : VftLog, b : VftLog) : Order.Order {
        if (a.token_apply_id < b.token_apply_id) { #less } else if (a.token_apply_id > b.token_apply_id) {
            #greater;
        } else {
            #equal;
        };
    };
    // func compareVftLog(a : VftLog, b : VftLog) : Order.Order {
    //     if (a.log_id < b.log_id) { #less } else if (a.log_id > b.log_id) {
    //         #greater;
    //     } else {
    //         #equal;
    //     };
    // };
    public func dealVftLog(param : VftLogParam, userTable : HashMap.HashMap<Nat, User>,
     tokenPlanTaskTable : [TokenPlanTask],log:Buffer.Buffer<Text>) : Result {
        let res = calculateUserVft(param, tokenPlanTaskTable,log);
        if (res.code != 200) {
            return res;
        };
        let user = getOrNewUer(param, userTable);
        let newLog = {
            amount = res.amount;
            customer_id = param.customer_id;
            source_id = param.source_id;
            source_code = param.source_code;
            remark = param.remark;
            order_no = param.order_no;
            create_time = param.create_time;
            token_apply_id = param.token_apply_id;
        };
        let userSet = Set.Make<VftLog>(compareVftLog);
        let size1=userSet.size(user.vft_logs);
        user.vft_logs := userSet.put(user.vft_logs, newLog);
        let size2=userSet.size(user.vft_logs);
        if(size2 > size1){
            user.vft_balance := user.vft_balance + res.amount;
        }else{
           return {
                code = 200;
                msg = "重复的数据";
            };
        };
        {
            code = 200;
            msg = "请求成功";
        };
    };

    public func calculateUserVft(param : VftLogParam, tokenPlanTasks : [TokenPlanTask],log:Buffer.Buffer<Text>) : {code:Nat;msg:Text;amount:Int} {
        let find = Array.find(
            tokenPlanTasks,
            func(task : TokenPlanTask) : Bool {
                let res = task.id == param.source_id;
                return res;
            },
        );
        switch (find) {
            case null {
                {
                    code = 500;
                    msg = "source_code invalid  source_code = " # param.source_code;
                    amount = 0;
                };
            };
            case (?find) {
                // log.add(debug_show("before ======>user.vft_balance=",user.vft_balance,"find=",find,"vftLog",vftLog));
                let am = param.amount * find.amount /100000000;
                log.add(debug_show("after ======>calculateUserVft am=",am,"param",param));
                {
                    code = 200;
                    msg = "请求成功";
                    amount = am;
                };
            };
        };
    };
    public func to_views(self : [TokenPlanTask]) : [TokenPlanTaskView] {
        return Array.map(self, to_view);
    };
    public func to_view(self : TokenPlanTask) : TokenPlanTaskView {
        return {
            id = self.id;
            name = self.name;
            code = self.code;
            amount = self.amount;
            create_by = self.create_by;
            create_time = self.create_time;
            update_by = self.update_by;
            update_time = self.update_time;
            remark = self.remark;
        };
    };

    public  func setToArray(set:Set.Set<VftLog>): [VftLog] {
        let userSet = Set.Make<VftLog>(compareVftLog);
        Iter.toArray(userSet.vals(set));
    };

    public func addIfNotExist(data : Text, list : List.List<Text>) : List.List<Text> {
        let exist = List.find(list, func(token : Text) : Bool { token == data });
        if (exist == null) {
            return List.push<Text>(data, list);
        } else {
            return list;
        };
    };

};
