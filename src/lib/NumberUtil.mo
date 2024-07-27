import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Int "mo:base/Int";
module{
    public func getIcpK8s(vftConut:Float,rate:Float):Nat{
        return Int.abs(Float.toInt((vftConut/3/rate)*100000000));
    }
}