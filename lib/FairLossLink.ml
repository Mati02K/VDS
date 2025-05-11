(* Send only one time *)

open Utils

module FairLossLink = struct
  type state = {
    id : int;
    mutable sent : message list;
    mutable delivered : message list;
  }

  let create id () = {
    id;
    sent = [];
    delivered = [];
  }

  (* True fair-loss: sends only once *)
  let send_once (link : state) (msg : message) (receiver : message -> unit) : unit =
    link.sent <- msg :: link.sent;
    Printf.printf "[FairLoss] Process %d sent message %d to %d\n"
      link.id msg.msgID msg.destination;
    flush stdout;
    receiver msg

  let deliver (link : state) (msg : message) : unit =
    link.delivered <- msg :: link.delivered;
    Printf.printf "[FairLoss] Process %d delivered message %d from %d\n"
      link.id msg.msgID msg.source;
    flush stdout
end
