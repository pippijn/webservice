open Lwt


let register_service =
  Json_registration.register_service Json.t<unit>
    ~path:["register"] ~get_params:Eliom_parameter.(string "user" ** string "pass")
    (fun (username, password) () ->
      lwt () = UserService.register username password in
      return ()
    )


let login_service =
  Json_registration.register_service Json.t<unit>
    ~path:["login"] ~get_params:Eliom_parameter.(string "user" ** string "pass")
    (fun (username, password) () ->
      lwt () = UserService.login username password in
      return ()
    )


let logout_service =
  Json_registration.register_user_service Json.t<unit>
    ~path:["logout"] ~get_params:Eliom_parameter.unit
    (fun username () () ->
      UserService.logout ();
      return ()
    )


type data = {
  username : string;
  password : string;
  stuff : int;
} deriving (Json)


let hello_service =
  Json_registration.register_user_service Json.t<data>
    ~path:["hello"] ~get_params:Eliom_parameter.unit
    (fun username () () ->
      return { username; password = "dunno"; stuff = 300; }
    )
