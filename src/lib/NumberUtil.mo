import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Char "mo:base/Char";
import Nat32 "mo:base/Nat32";
module {
    public func getIcpK8s(vftConut : Float, rate : Float) : Nat {
        return Int.abs(Float.toInt((vftConut / 3 / rate) * 100000000));
    };

    public func textToNat(txt : Text) : Nat {
        var num : Nat = 0;
        for (c in txt.chars()) {
            assert (Char.isDigit(c));
            let charToNat : Nat = Nat32.toNat(Char.toNat32(c) - 48);
            num := num * 10 + charToNat;
        };
        num;
    };
};
