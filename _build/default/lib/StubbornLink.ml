(* Properties 
SL1. Stubborn delivery.
• If a correct process pi sends a message m to a correct process pj, then pj delivers m, an infinite number of times.
SL2. No creation:
• No message is delivered unless it was sent.
*)

open Utils
open FairLossLink

module StubbornLink = struct
  type state = {
    id : int;
    fair_loss : FairLossLink.state;
    mutable retries : int;
    max_retries : int;
  }

  let create id ?(max_retries = max_int) port = {
    id;
    fair_loss = FairLossLink.create id port;
    retries = 0;
    max_retries;
  }

  let send (link : state) (msg : message) (dest_ip : string) (dest_port : int) : unit =
    while link.retries < link.max_retries do
      let timestamp = Unix.gettimeofday () in
      Printf.printf "[TIME] Retry #%d for message %d at %.4f\n"
        link.retries msg.msgID timestamp;
      flush Stdlib.stdout;

      Printf.printf "[STUBBORNLINK] Retry #%d for message %d\n" link.retries msg.msgID;
      flush Stdlib.stdout;

      FairLossLink.send link.fair_loss msg dest_ip dest_port;
      link.retries <- link.retries + 1;

      Unix.sleepf 0.01
    done

  let receive (link : state) : message option =
    FairLossLink.receive link.fair_loss
end
