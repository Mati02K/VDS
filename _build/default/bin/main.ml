open VDS.Utils
open VDS.PerfectLink

(* Create sender and receiver perfect links *)
let sender_link = PerfectLink.create 1 ~max_retries:3 ()
let receiver_link = PerfectLink.create 2 ~max_retries:3 ()

(* Receiver function: delivers and processes the message once *)
let receiver_fn msg =
  PerfectLink.deliver receiver_link msg (fun delivered_msg ->
    Printf.printf "[Main] Delivered message %d: %s\n"
      delivered_msg.msgID delivered_msg.content;
    flush stdout
  )

(* Create the DATA message to send *)
let msg = {
  msgID = 42;
  source = 1;
  destination = 2;
  content = "Hello from PerfectLink";
}

let () =
  Printf.printf "--- Starting Perfect Link Test ---\n";
  flush stdout;

  (* Sender sends the message to the receiver *)
  PerfectLink.send sender_link msg receiver_fn
