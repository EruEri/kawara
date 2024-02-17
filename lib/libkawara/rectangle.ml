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

type t = {
  x: int;
  y: int;
  width: int;
  height: int;
}

let divide orientation rectangle = 
  let {x; y; width; height} = rectangle in
  match orientation with
  | Orientation.Vertical -> 
    let new_width = width / 2 in
    let lhs = {x; y; width = new_width; height} in
    let rhs = {x = x + new_width; y; width = new_width; height} in
    (lhs, rhs)
  | Horizontal -> 
    let new_height = height / 2 in
    let top = {x; y; width; height = new_height} in 
    let bottom = {x; y = y + new_height; width; height = new_height} in
    (top, bottom)
