type process_id = int
type msgID = int


type message = {
  msgID : msgID;
  source : process_id;
  destination : process_id;
  content : string;
}



