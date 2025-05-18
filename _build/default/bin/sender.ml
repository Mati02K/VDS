open VDS.PerfectLink
open VDS.Utils

let () =
  (* Create PerfectLink sender with process ID 1 on port 8000 *)
  let plink = PerfectLink.create 1 ~max_retries:5 8000 in

  let msg = {
    msgID = 1;
    source = 11;           
    destination = 21;    
    content = "Mathesh Sending msg through Perfect Links";
  } in

  (* Using local host address and use receiver's 9000 port*)
  let dest_ip = "127.0.0.1" in
  let dest_port = 9000 in

  Printf.printf "[APP : SENDER] Sending message %d to %s:%d...\n"
    msg.msgID dest_ip dest_port;
  flush Stdlib.stdout;

  PerfectLink.send plink msg dest_ip dest_port
