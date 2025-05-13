(* Properties 
FL1. Fair-loss:
• If a message is sent infinitely often by pi to pj, and neither pi or pj crash, then m is delivered infinitely often to pj. ( sent = received)
FL2. Finite duplication:
• If a message is sent a finite number of times by pi to pj, it is not delivered an infinite number of times to pj. ( sent ≠ received)
FL3. No creation:
• No message is delivered unless it was sent.
*)

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

  let send (link : state) (msg : message) (receiver : message -> unit) : unit =
    link.sent <- msg :: link.sent;
    Printf.printf "[FAIRLOSS] Process %d sent message %d to %d\n"
      link.id msg.msgID msg.destination;
    flush stdout;
    receiver msg

  let deliver (link : state) (msg : message) : unit =
    link.delivered <- msg :: link.delivered;
    Printf.printf "[FAIRLOSS] Process %d delivered message %d from %d\n"
      link.id msg.msgID msg.source;
    flush stdout
end
