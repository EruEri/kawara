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

let rec event tree () = 
  let tree, update =  match Cbindings.Xcb.wait_event ewmh with
  | None -> 
    let () = Printf.eprintf "Event error : \n" in
    tree, false
  | Some XcbIgnoreEvent -> 
    let () = Printf.printf "ignore event : \n" in
    tree, false
  | Some XcbCreate window -> 
    let () = Printf.printf "Create windows : %lu\n" (Obj.magic window) in
    let tree = Libkawara.Tree.add Vertical window tree in
    tree, true
  | Some XcbDestroy window -> 
    let () = Printf.printf "Destropy windows : %lu\n" (Obj.magic window) in
    tree, false
  in
  let () = flush stdout in
  let () = match update with
    | true -> Libkawara.Tree.layout ewmh tree
    | false -> ()
  in
  event tree ()

let () = event (Libkawara.Tree.empty {x = 0; y = 26; width = 2560; height = 1574}) ()

  
 