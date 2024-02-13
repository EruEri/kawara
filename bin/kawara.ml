let getm message = function
| Some s -> s
| None -> 
  let () = Printf.eprintf "Error : %s\n" message in
  exit 1

let xcb =  getm "Create connection" @@ Cbindings.Xcb.xcb_connection ()

let ewmh = getm "Create ewmh" @@ Cbindings.Xcb.xcb_ewmh_connection_init xcb

let current_desktop = getm "Get desktop" @@ Cbindings.Ewmh.current_desktop ewmh 

let () = Printf.printf "current desktop = %u\n" current_desktop

let (width, height) = getm "Get dimension" @@ Cbindings.Ewmh.desktop_dimension ewmh current_desktop 

let () = Printf.printf "Dimentions : width = %u, heigth = %u\n" width height
