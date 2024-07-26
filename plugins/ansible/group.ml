type t = { configs : Config.t list }

let configs t = t.configs
let marshal { configs } = Yojson.Safe.to_string @@ `Assoc [ ("configs", `List (List.map (fun p -> `String (Config.marshal p)) configs)) ]

let unmarshal s =
  let open Yojson.Safe.Util in
  let json = Yojson.Safe.from_string s in
  let configs =
    json |> member "configs" |> to_list
    |> List.map (fun el ->
           match el with
           | `String s -> Config.unmarshal s
           | _ -> failwith "Expected config")
  in
  { configs }
