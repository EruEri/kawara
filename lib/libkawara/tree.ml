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

type t = 
  | Leaf of {
    rectangle: Rectangle.t;
    window: Cbindings.Xcb.Window.t option
  }
  | Node of {
    lhs: t; 
    rhs: t
  }
let empty rectangle = Leaf {rectangle; window = None}

let rec add orientation window = function
  | Leaf {rectangle; window = None} -> Leaf {rectangle; window = Some window}
  | Leaf {rectangle; window = Some _ as w } -> 
    let (lhs, rhs) = Rectangle.divide orientation rectangle in 
    Node {
      lhs = Leaf {rectangle = lhs; window = w};
      rhs = Leaf {rectangle = rhs; window = Some window}
    }
  | Node {lhs; rhs} -> 
    Node {lhs; rhs = add (Orientation.toggle orientation) window rhs}


let rec layout connection = function
  | Leaf {rectangle = _; window = None} -> ()
  | Leaf {rectangle; window = Some w } -> 
    let Rectangle.{x; y; width; height} = rectangle in
    Cbindings.Xcb.move_window connection w ~x ~y ~width ~height
  | Node {lhs; rhs} -> 
    let () = layout connection lhs in
    layout connection rhs