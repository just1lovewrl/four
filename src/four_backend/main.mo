import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
actor {
 
    // Message记录结构
    public type Message = {
        text : Text;
        time : Time.Time;
    };
 
    public type Microblog = actor{
        follow: shared(Principal) -> async ();
        follows: shared query () -> async [Principal];
        post: shared (Text) -> async ();
        posts: shared query () -> async [Message];
        timeline : shared () -> async [Message];
    };
 
    var followed : List.List<Principal> = List.nil();
 
    public shared func follow(id: Principal) : async () {
        followed := List.push(id,followed);
    };
 
    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    };
 
    var messages : List.List<Message> = List.nil();
    
    // 在post方法中，创建新的Message并记录当前时间
    public shared func post(text : Text) : async () {
        let mesg : Message = {
            text = text;
            time = Time.now();
        };
        messages := List.push(mesg, messages);
    };
 
    public shared query func posts() : async [Message] { 
        List.toArray(messages)
    };
 
    public shared func timeline() : async [Message] {
        var all : List.List<Message> = List.nil();
        for(id in Iter.fromList(followed)){
            let canister :Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts();
            for (msg in Iter.fromArray(msgs)){
                all := List.push(msg,all)
            }
        };
        List.toArray(all)
    };
};