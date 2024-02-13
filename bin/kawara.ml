let getm message = function
| Some s -> s
| None -> 
  let () = Printf.eprintf "Error : %s\n" message in
  exit 1

let xcb =  getm "Create connection" @@ Cbindings.Xcb.xcb_connection ()

let ewmh = getm "Create ewmh" @@ Cbindings.Xcb.xcb_ewmh_connection_init xcb

let current_desktop = getm "Get desktop" @@ Cbindings.Ewmh.current_desktop ewmh 

let () = Printf.printf "current desktop = %u\n" current_desktop

let (width, height) = getm "Get dimension" @@ Cbindings.Ewmh.desktop_dimension ewmh 0 

let Cbindings.Ewmh.{orientation; rows; columns; starting_corner} = getm "Layout" @@ Cbindings.Ewmh.desktop_layout ewmh 0

let () = Printf.printf "Dimentions : width = %u, heigth = %u\n" width height

let () = Printf.printf "Orientation = %u Rows = %u, columns = %u, corner = %u\n" orientation rows columns starting_corner