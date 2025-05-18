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
    mutable delivered_ids : MsgIdSet.t;   (* Set of already delivered message IDs *)
    inbox : message Queue.t;              (* Incoming message buffer *)
  }

  let create id ?(max_retries = max_int) port =
    {
      id;
      stubborn = StubbornLink.create id ~max_retries port;
      delivered_ids = MsgIdSet.empty;
      inbox = Queue.create ();
    }

  (* Sending using stubborn link; receiver is expected to be listening on dest_ip:dest_port *)
  let send (link : state) (msg : message) (dest_ip : string) (dest_port : int) : unit =
    StubbornLink.send link.stubborn msg dest_ip dest_port

  (* Receiver callback: push message to inbox *)
  let receiver_callback (link : state) : message -> unit =
    fun msg ->
      Queue.push msg link.inbox

  (* Listening loop — delivers each message at most once *)
  let deliver (link : state) (process : message -> unit) : unit =
    while true do
      if not (Queue.is_empty link.inbox) then (
        let msg = Queue.pop link.inbox in
        if not (MsgIdSet.mem msg.msgID link.delivered_ids) then begin
          let timestamp = Unix.gettimeofday () in
          Printf.printf "[TIME] Delivered message %d from %d at %.4f with content: %s\n"
            msg.msgID msg.source timestamp msg.content;
          flush Stdlib.stdout;

          Printf.printf "[PERFECTLINK] Delivered message %d from %d: %s\n"
            msg.msgID msg.source msg.content;
          flush Stdlib.stdout;

          link.delivered_ids <- MsgIdSet.add msg.msgID link.delivered_ids;
          process msg
        end
      );
      Unix.sleepf 0.01
    done
end