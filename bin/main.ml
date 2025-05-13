open VDS.Utils
open VDS.PerfectLink

(* Simulate a component with multiple perfect links *)
module Component = struct
  type t = {
    id : int;
    (* Storing all Perfect Links here *)
    links : (int, PerfectLink.state) Hashtbl.t;  
  }

  let create id port_count ~max_retries =
    let tbl = Hashtbl.create port_count in
    for port = 1 to port_count do
      Hashtbl.add tbl port (PerfectLink.create (id * 10 + port) ~max_retries ())
    done;
    { id; links = tbl }

  let get_link component port =
    Hashtbl.find component.links port
end

let () =
  let components = Array.init 2 (fun i ->
    Component.create (i + 1) 1 ~max_retries: 3
  ) in

  let c1 = components.(0) in
  let c2 = components.(1) in
  let c1p1 = Component.get_link c1 1 in
  let c2p1 = Component.get_link c2 1 in

  (* Deliver thread *)
  let _receiver_thread = Thread.create (fun () ->
    Printf.printf "[MAIN] Listening for messages...\n";
    flush stdout;
    PerfectLink.deliver c2p1 (fun msg ->
      Printf.printf "[MAIN] Delivered message %d: %s\n" msg.msgID msg.content;
      flush stdout
    )
  ) () in

  (* Sender thread *)
  let _sender_thread = Thread.create (fun () ->
    (* TODO :- Implement id's dyunamically *)
    let msg = {
      msgID = 1;
      source = 11;
      destination = 21;
      content = "Message from C1P1";
    } in
    Printf.printf "[MAIN] Sending message...\n";
    flush stdout;
    (* send it to C2P1 queue so that it can deliver if it can actually reach there *)
    PerfectLink.send c1p1 msg (fun m -> Queue.push m c2p1.inbox)
  ) () in

  Thread.delay 2.0  (* Letting the thread so that the main thread does not suspend it quickly without delivering *)

