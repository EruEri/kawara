type 'a non_empty = 
  | Leaf of 'a
  | Node of 'a * 'a non_empty


type 'a t = 
  | Empty 
  | Tree of 'a non_empty


let rec add elt = function
  | Leaf e -> Node (e, Leaf elt) 
  | Node (e, node) -> Node (e, add elt node)

let add elt = function
  | Empty -> Tree (Leaf elt)
  | Tree e -> Tree (add elt e)


