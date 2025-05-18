(* Properties 
FL1. Fair-loss:
• If a message is sent infinitely often by pi to pj, and neither pi or pj crash, then m is delivered infinitely often to pj. ( sent = received)
FL2. Finite duplication:
• If a message is sent a finite number of times by pi to pj, it is not delivered an infinite number of times to pj. ( sent ≠ received)
FL3. No creation:
• No message is delivered unless it was sent.
*)

(* fair_loss_link.ml *)

open Utils

module FairLossLink = struct
  type state = {
    id : int;
    socket : Unix.file_descr;
    mutable sent : message list;
    mutable delivered : message list;
  }

  let create id port : state =
    let sock = create_udp_socket port in
    {
      id;
      socket = sock;
      sent = [];
      delivered = [];
    }

  let send (link : state) (msg : message) (dest_ip : string) (dest_port : int) : unit =
    link.sent <- msg :: link.sent;
    send_udp_message link.socket msg dest_ip dest_port;
    Printf.printf "[FAIRLOSS] Process %d sent message %d to %s:%d\n"
      link.id msg.msgID dest_ip dest_port;
    flush Stdlib.stdout

  let receive (link : state) : message option =
    match try_receive_udp_message link.socket with
    | Some msg ->
        link.delivered <- msg :: link.delivered;
        Printf.printf "[FAIRLOSS] Process %d received message %d from %d\n"
          link.id msg.msgID msg.source;
        flush Stdlib.stdout;
        Some msg
    | None -> None
end
