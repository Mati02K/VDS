(* open VDS.Utils
open VDS.FairLossLinks

(* Create FairLossLinks for both processes *)
let link1 = FairLossLinks.create 1 ()
let link2 = FairLossLinks.create 2 ()

(* ACK handler on P1 — marks the message as acknowledged *)
let ack_handler_on_p1 ack_msg =
  Printf.printf "Process %d received ACK for message %d from %d\n"
    ack_msg.destination ack_msg.msgID ack_msg.source;
  flush stdout;

  FairLossLinks.mark_ack link1 ack_msg.msgID;

  exit 0
  (* Exit after receiving ACK for demonstration purposes *)

(* Receiver logic on P2 — delivers and sends ACK back *)
let receiver_process2 msg =
  FairLossLinks.deliver link2 msg (fun ack ->
    FairLossLinks.send link2 ack ack_handler_on_p1
  )

(* Original message from P1 to P2 *)
let msg = {
  msgID = 1001;
  source = 1;
  destination = 2;
  content = "Hello from P1";
}

let () =
  Printf.printf "--- Starting Fair-Loss Message Send ---\n";
  flush stdout;
  FairLossLinks.send link1 msg receiver_process2 *)
