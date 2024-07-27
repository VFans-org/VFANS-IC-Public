import List "mo:base/List";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
import Int "mo:base/Int";
import TimeUtil "TimeUtil";

// type TextSet = List.List<Text>;
module {
    type LogType = { #simple;#query_icp_rate;#query_icp_usd_rate };

    //定义一个List
    public type LogSet = List.List<Log>;

    public type Log={
        log_id:Int;
        time:Int;
        log_type:LogType;
        content:Text;
    };

    //查询 日志记录数
    public func  query_log_count(logs:LogSet ):Int {
        return List.size(logs);
    };
    //添加日志
    public func add_log(logs:LogSet,logType:LogType,content:Text):LogSet {
        //利用入参构造log对象
        let log = {
            log_id=TimeUtil.getCurrentSecond();
            time=TimeUtil.getCurrentSecond();
            log_type=logType;
            content=content;
        };
        return List.push<Log>(log,logs);
    };
    //根据log_type 筛选日志
    public func filter_log_by_log_id(logs:LogSet,log_type:LogType):LogSet {
        let filter_func = func(log:Log):Bool {
            return log.log_type == log_type;
        };
        return List.filter<Log>(logs,filter_func);
    };

};
