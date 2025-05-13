(* PL1. Validity.
• If pi and pj are correct, then every message sent by pi to pj is eventually delivered by pj.
PL2. No duplication:
• No message is delivered to a process more than once.
PL3. No creation:
• No message is delivered unless it was sent *)

open Utils
open StubbornLink

module PerfectLink = struct
  module MsgIdSet = Set.Make(Int)

  type state = {
    id : int;
    stubborn : StubbornLink.state;
    mutable delivered_ids : MsgIdSet.t; (* will store the list of messages that are sent so that it doen't have to retry again*)
    inbox : message Queue.t; (* this is where we actually receive msg's. If there is a change it will be detect in while loop *)
  }

  let create id ?(max_retries = max_int) () = {
    id;
    stubborn = StubbornLink.create ~max_retries:max_retries id ();
    delivered_ids = MsgIdSet.empty;
    inbox = Queue.create ();
  }

  let send (link : state) (msg : message) (receiver : message -> unit) : unit =
    StubbornLink.send link.stubborn msg receiver

  (* Let this run forever so that it mimicks likes listening forever *)
  let deliver (link : state) (process : message -> unit) : unit =
    while true do
      if not (Queue.is_empty link.inbox) then (
        let msg = Queue.pop link.inbox in
        if not (MsgIdSet.mem msg.msgID link.delivered_ids) then begin
          let timestamp = Unix.gettimeofday () in
          Printf.printf "[TIME] Delivered message %d from %d at %.4f with content: %s\n"
            msg.msgID msg.source timestamp msg.content;
          flush stdout;

          Printf.printf "[PERFECTLINK] Delivered message %d from %d: %s\n"
            msg.msgID msg.source msg.content;
          flush stdout;
          link.delivered_ids <- MsgIdSet.add msg.msgID link.delivered_ids;
          process msg
        end
      );
      Unix.sleepf 0.01
    done
    
end
