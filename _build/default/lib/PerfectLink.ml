open Utils
open StubbornLink

module PerfectLink = struct
  module MsgIdSet = Set.Make(Int)

  type state = {
    id : int;
    stubborn : StubbornLink.state;
    mutable delivered_ids : MsgIdSet.t;
    inbox : message Queue.t;
  }

  let create id ?(max_retries = max_int) () = {
    id;
    stubborn = StubbornLink.create ~max_retries:max_retries id ();
    delivered_ids = MsgIdSet.empty;
    inbox = Queue.create ();
  }

  let send (link : state) (msg : message) (receiver : message -> unit) : unit =
    StubbornLink.send link.stubborn msg receiver

  (* Wait and listen forever and only end if the message has been received. *)
  let deliver (link : state) (process : message -> unit) : unit =
    while true do
      if not (Queue.is_empty link.inbox) then (
        let msg = Queue.pop link.inbox in
        if not (MsgIdSet.mem msg.msgID link.delivered_ids) then begin
          let timestamp = Unix.gettimeofday () in
          Printf.printf "[DELIVER] Delivered message %d from %d at %.4f with content: %s\n"
            msg.msgID msg.source timestamp msg.content;
          flush stdout;

          Printf.printf "[PerfectLink] Delivered message %d from %d: %s\n"
            msg.msgID msg.source msg.content;
          flush stdout;
          link.delivered_ids <- MsgIdSet.add msg.msgID link.delivered_ids;
          process msg
        end
      );
      Unix.sleepf 0.01
    done
    
end
