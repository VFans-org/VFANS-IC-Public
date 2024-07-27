import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Bool "mo:base/Bool";
import Debug "mo:base/Debug";
import Sha256 "../nft_backend/SHA256";
import Hex "Hex";
module {

    public func get_sign_str(paramList : [Text], secret_key : Text) : Text {
        var sinStr = "";
        for (i in Iter.range(0, Array.size(paramList) -1)) {
            let param = paramList[i];
            sinStr := sinStr # param # ",";
        };
        sinStr := sinStr # secret_key;
        Debug.print(sinStr # "--------------------------");
        return sinStr;
    };

    public func sign_param(paramList : [Text], secret_key : Text) : Text {
        return Hex.encode(Sha256.sha256_with_text(get_sign_str(paramList,secret_key)));
    };
    public func check_sign(paramList : [Text], sign : Text, secret_key : Text) : Bool {
        return Text.equal(sign_param(paramList, secret_key), sign);
    };
};
