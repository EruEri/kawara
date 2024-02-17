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


module Window = struct
  type t

  external compare: t -> t -> int = "caml_xcb_window_compare"

  let equal lhs rhs = compare lhs rhs = 0
end


type xcb_connection
type xcb_ewmh_connection

type xcb_event = 
  | XcbIgnoreEvent
  | XcbCreate of Window.t
  | XcbDestroy of Window.t

external xcb_connection: unit -> xcb_connection option = "caml_xcb_connection"
external xcb_disconnect: xcb_connection -> unit = "caml_xcb_disconnect"
external xcb_ewmh_connection_init: xcb_connection -> xcb_ewmh_connection option = "caml_xcb_ewmh_connection_init"
external xcb_ewmh_connection_destroy: xcb_ewmh_connection -> unit = "caml_xcb_ewmh_connection_destroy"

external wait_event : xcb_ewmh_connection -> xcb_event option = "caml_xcb_wait_for_event"