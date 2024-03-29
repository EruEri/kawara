(**********************************************************************************************)
(*                                                                                            *)
(* This file is part of kawara: An litle X tiling program                                     *)
(* Copyright (C) 2024 Yves Ndiaye                                                             *)
(*                                                                                            *)
(* kawara is free software: you can redistribute it and/or modify it under the terms          *)
(* of the GNU General Public License as published by the Free Software Foundation,            *)
(* either version 3 of the License, or (at your option) any later version.                    *)
(*                                                                                            *)
(* kawara is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;        *)
(* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           *)
(* PURPOSE.  See the GNU General Public License for more details.                             *)
(* You should have received a copy of the GNU General Public License along with kawara.       *)
(* If not, see <http://www.gnu.org/licenses/>.                                                *)
(*                                                                                            *)
(**********************************************************************************************)


type xbc_any_event

type xbc_button_press_event
type xbc_create_notify_event

type xcb_generic_event = 
| XcbAnyEvent of xbc_any_event
| XcbButtonPress of xbc_button_press_event
| XcbCreateNotify of xbc_create_notify_event


type desktop_layout = {
  orientation: int;
  columns: int;
  rows: int;
  starting_corner: int
}

type geometry = {
  x: int;
  y: int;
  width: int;
  height: int;
}


external current_desktop : Xcb.xcb_ewmh_connection -> int option = "caml_xcb_ewmh_get_current_desktop"

external number_of_desktops: Xcb.xcb_ewmh_connection -> int -> int option = "caml_xcb_ewmh_get_number_of_desktops"
(*
width, height   
*)
external desktop_dimension : Xcb.xcb_ewmh_connection -> int -> (int * int) option = "caml_xcb_ewmh_get_desktop_geometry"

external desktop_layout: Xcb.xcb_ewmh_connection -> int -> desktop_layout option = "caml_xcb_ewmh_connection_get_desktop_layout"

external workareas: Xcb.xcb_ewmh_connection -> int -> geometry array option = "caml_xcb_get_workarea"
