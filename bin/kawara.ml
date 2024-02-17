let getm message = function
| Some s -> s
| None -> 
  let () = Printf.eprintf "Error : %s\n" message in
  exit 1

let xcb =  getm "Create connection" @@ Cbindings.Xcb.xcb_connection ()

let ewmh = getm "Create ewmh" @@ Cbindings.Xcb.xcb_ewmh_connection_init xcb

let current_desktop = getm "Get desktop" @@ Cbindings.Ewmh.current_desktop ewmh 

let desktop_count = getm "Desktop count" @@ Cbindings.Ewmh.number_of_desktops ewmh 0

let () = Printf.printf "current desktop = %u\n" current_desktop

let (width, height) = getm "Get dimension" @@ Cbindings.Ewmh.desktop_dimension ewmh 0 

let Cbindings.Ewmh.{orientation; rows; columns; starting_corner} = getm "Layout" @@ Cbindings.Ewmh.desktop_layout ewmh 0

let () = Printf.printf "Dimentions : width = %u, heigth = %u\n" width height

let () = Printf.printf "Orientation = %u Rows = %u, columns = %u, corner = %u\n" orientation rows columns starting_corner

let () = Printf.printf "Number of desktop = %u\n" desktop_count

let () = Array.iteri (fun i geometry -> 
  Printf.printf "index = %u, x = %u, y = %u, width = %u, height = %u\n" i geometry.Cbindings.Ewmh.x geometry.y geometry.width geometry.height
  ) @@ getm "Working areas" @@ Cbindings.Ewmh.workareas ewmh 0


let () = flush stdout

let rec event () = 
  let () =  match Cbindings.Xcb.wait_event ewmh with
  | None -> Printf.eprintf "Event error : \n"
  | Some XcbIgnoreEvent -> Printf.printf "ignore event : \n"
  | Some XcbCreate window -> 
    Printf.printf "Create windows : %lu\n" (Obj.magic window)
  | Some XcbDestroy window -> 
      Printf.printf "Destropy windows : %lu\n" (Obj.magic window) 
  in
  let () = flush stdout in
  event ()

let () = event ()

  
 