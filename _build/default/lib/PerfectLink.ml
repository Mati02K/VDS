open Utils
open StubbornLink

module PerfectLink = struct
  module MsgIdSet = Set.Make(Int)

  type state = {
    id : int;
    stubborn : StubbornLink.state;
    mutable delivered_ids : MsgIdSet.t;
  }

  let create id ?(max_retries = max_int) () = {
    id;
    stubborn = StubbornLink.create ~max_retries:max_retries id ();
    delivered_ids = MsgIdSet.empty;
  }

  let send (link : state) (msg : message) (receiver : message -> unit) : unit =
     if not (MsgIdSet.mem msg.msgID link.delivered_ids) then
      StubbornLink.send link.stubborn msg receiver

  let deliver (link : state) (msg : message) (process : message -> unit) : unit =
    if not (MsgIdSet.mem msg.msgID link.delivered_ids) then begin
      link.delivered_ids <- MsgIdSet.add msg.msgID link.delivered_ids;
      process msg
    end
    
end
