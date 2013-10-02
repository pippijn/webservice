type error = {
  kind : string;
  message : string option;
} deriving (Json)


let send ?code t data =
  Eliom_registration.String.send
    (Deriving_Json.to_string t data, "application/json")


let register_service t fn =
  Eliom_registration.Any.register_service
    (fun args () ->
      try_lwt
        lwt data = fn args () in
        send t data
      with

      | UserService.E error ->
          let open UserService.E in
          begin match error with
          | Already_logged_in name ->
              let error = { kind = "Already_logged_in"; message = Some name; } in
              send ~code:403 Json.t<error> error
          | Already_registered ->
              let error = { kind = "Already_registered"; message = None; } in
              send ~code:403 Json.t<error> error
          | Bad_credentials ->
              let error = { kind = "Bad_credentials"; message = None; } in
              send ~code:403 Json.t<error> error
          | Not_logged_in ->
              let error = { kind = "Not_logged_in"; message = None; } in
              send ~code:403 Json.t<error> error
          end

      | Failure message ->
          let error = { kind = "Failure"; message = Some message; } in
          send ~code:500 Json.t<error> error
    )


let register_user_service t fn =
  register_service t
    (UserService.user_service fn)
