(* 
Unix Reference:  https://ocaml.org/manual/5.3/api/Unix.html
*)
open Unix

type process_id = int
type msgID = int

type message = {
  msgID : msgID;
  source : process_id;
  destination : process_id;
  content : string;
}

(* 
Create a UDP socket with IPv4 
Create a address structure which listenes to any address on the all ports
Bind the socket to the address
Return the address.
*)
let create_udp_socket bound_port : file_descr =
  let sock = socket PF_INET SOCK_DGRAM 0 in
  let addr = ADDR_INET (inet_addr_any, bound_port) in
  bind sock addr;
  sock

(*
Using Marshal to turn msg into a byte (Doc Reference: https://ocaml.org/manual/5.3/api/Marshal.html
Using sendto instead of send(TCP) because we are using UDP
Sending data as bytes over the network also return void.
*)
let send_udp_message (sock : file_descr) (msg : message) (dest_ip : string) (dest_port : int) : unit =
  let remote_addr = ADDR_INET (inet_addr_of_string dest_ip, dest_port) in
  let serialized = Marshal.to_bytes msg [Marshal.Closures] in
  let _ = sendto sock serialized 0 (Bytes.length serialized) [] remote_addr in
  ()

(* 
Try to receive a message from the socket.
Setting a buffer of 2048 bytes. If the message is larger, it will be truncated and also lost due to prop of UDP.
So we should consider using a large buffer if the requirement changes.
I am just printing error msg and returning none to make sure program does not crash.
*)
let try_receive_udp_message (sock : file_descr) : message option =
  let buffer = Bytes.create 2048 in
  try
    let (_, _) = recvfrom sock buffer 0 2048 [] in
    let msg : message = Marshal.from_bytes buffer 0 in
    Some msg
  with ex ->
    Printf.eprintf "[UITLS] ERROR :- Failed to receive or decode message: %s\n" (Printexc.to_string ex);
    flush Stdlib.stderr;
    None
