import List "mo:base/List";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";

// type TextSet = List.List<Text>;
module {

    public func add(data : Text, list : List.List<Text>) : List.List<Text> {
        let exist = List.find(list, func(token : Text) : Bool { token == data });
        if (exist == null) {
            return List.push<Text>(data, list);
        } else {
            return list;
        };
    };
};
