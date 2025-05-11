open VDS.Utils
open VDS.StubbornLink

let receiver_process msg =
  Printf.printf "[Receiver] Received message %d from %d: %s\n"
    msg.msgID msg.source msg.content;
  flush stdout

let () =
  let link = StubbornLink.create 1 ~max_retries:3 () in

  let msg = {
    msgID = 42;
    source = 1;
    destination = 2;
    content = "Hello from stubborn sender!";
  } in

  Printf.printf "--- StubbornLink Test ---\n";
  flush stdout;

  StubbornLink.send link msg receiver_process
