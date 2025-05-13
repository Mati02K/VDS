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

  (* recursion Approach *)
  (* let rec send (link : state) (msg : message) (receiver : message -> unit) : unit =
    if link.retries < link.max_retries then begin
      Printf.printf "[Stubborn] Retry #%d for message %d\n" link.retries msg.msgID;
      flush stdout;
      FairLossLink.send_once link.fair_loss msg receiver;
      link.retries <- link.retries + 1;
      send link msg receiver
    end *)

  (* Iteration Approach *)
  let send (link : state) (msg : message) (receiver : message -> unit) : unit =
    while link.retries < link.max_retries do
      let timestamp = Unix.gettimeofday () in
      Printf.printf "[Stubborn] Retry #%d for message %d at %.4f\n"
        link.retries msg.msgID timestamp;
      flush stdout;

      Printf.printf "[Stubborn] Retry #%d for message %d\n" link.retries msg.msgID;
      flush stdout;
      FairLossLink.send link.fair_loss msg receiver;
      link.retries <- link.retries + 1;
      Unix.sleepf 0.01
    done

  let deliver = FairLossLink.deliver
end
