open Lwt


let register_service =
  Json_registration.register_service Json.t<unit>
    ~path:["register"] ~get_params:Eliom_parameter.(string "user" ** string "pass")
    (fun (username, password) () ->
      UserService.register username password)


let login_service =
  Json_registration.register_service Json.t<unit>
    ~path:["login"] ~get_params:Eliom_parameter.(string "user" ** string "pass")
    (fun (username, password) () ->
      UserService.login username password)


let logout_service =
  Json_registration.register_user_service Json.t<unit>
    ~path:["logout"] ~get_params:Eliom_parameter.unit
    (fun user () () ->
      return (UserService.logout ()))


type data = {
  username : string;
  password : string;
  stuff : int;
} deriving (Json)


let hello_service =
  Json_registration.register_user_service Json.t<data>
    ~path:["hello"] ~get_params:Eliom_parameter.unit
    (fun user () () ->
      return {
        username = User.(user.id);
        password = "dunno";
        stuff = 300;
      })
