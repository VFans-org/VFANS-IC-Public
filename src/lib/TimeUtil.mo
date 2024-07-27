import Time "mo:base/Time";
import Bool "mo:base/Bool";
import Nat64 "mo:base/Nat64";
module {
    public func getCurrentSecond() : Int {
        return (Time.now() / 1_000_000_000);
    };


    public func checkTimeout(time:Nat) : Bool {
        return getCurrentSecond()-time < 6000;
    };
};
