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

  let rec send (link : state) (msg : message) (receiver : message -> unit) : unit =
    if link.retries < link.max_retries then begin
      Printf.printf "[Stubborn] Retry #%d for message %d\n" link.retries msg.msgID;
      flush stdout;
      FairLossLink.send_once link.fair_loss msg receiver;
      link.retries <- link.retries + 1;
      send link msg receiver
    end

  let deliver = FairLossLink.deliver
end
