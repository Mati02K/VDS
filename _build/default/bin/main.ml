(* TODO
1. Need to work on handlers on each layers.
2. Need to group components.
3. Need dynamic way of creating ID's. 
*)

open VDS.FairLossLink
open VDS.PerfectLink

let () =
  (* Create PerfectLink with process ID 2, listening on port 9000 *)
  let plink = PerfectLink.create 2 ~max_retries:0 9000 in

  (* Start background thread to receive UDP packets and enqueue them *)
  let _ = Thread.create (fun () ->
    while true do
      match FairLossLink.receive plink.stubborn.fair_loss with
      | Some msg ->
          Printf.printf "[APP : RECEIVER] Received message %d from %d. Enqueuing...\n"
            msg.msgID msg.source;
          flush Stdlib.stdout;
          (PerfectLink.receiver_callback plink) msg
      | None ->
        (* Just like my thread approach I am waiting for some time and trying again. *)
          Unix.sleepf 0.01
    done
  ) () in

  Printf.printf "[APP : RECEIVER] Listening on port 9000...\n";
  flush Stdlib.stdout;

  (* Main thread: Run the PerfectLink delivery *)
  PerfectLink.deliver plink (fun msg ->
    Printf.printf "[APP : RECEIVER] Delivered to application: %s\n" msg.content;
    flush Stdlib.stdout
  )
