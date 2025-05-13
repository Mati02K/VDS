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

  let create id ?(max_retries = max_int) () = {
    id;
    fair_loss = FairLossLink.create id ();
    retries = 0;
    max_retries;
  }

  let send (link : state) (msg : message) (receiver : message -> unit) : unit =
    while link.retries < link.max_retries do
      let timestamp = Unix.gettimeofday () in
      Printf.printf "[TIME] Retry #%d for message %d at %.4f\n"
        link.retries msg.msgID timestamp;
      flush stdout;

      Printf.printf "[STUBBORNLINK] Retry #%d for message %d\n" link.retries msg.msgID;
      flush stdout;
      FairLossLink.send link.fair_loss msg receiver;
      link.retries <- link.retries + 1;
      (* Adding this so that deliver has some breathing space to deliver *)
      Unix.sleepf 0.01
    done

  let deliver = FairLossLink.deliver
end
