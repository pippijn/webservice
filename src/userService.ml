module E = struct
  type t =
    | Already_logged_in of string
    | Already_registered
    | Bad_credentials
    | Not_logged_in
end

exception E of E.t
let die error = raise_lwt (E error)


(* Non-persistent session variable doesn't need Lwt. *)
let user = Eliom_reference.Volatile.eref
  ~scope:Eliom_common.default_session_scope
  None

(* Persistent user store with username/hash pairs. *)
let users = Eliom_reference.eref
  ~scope:Eliom_common.global_scope
  ~persistent:"users"
  []


(* Add new user to store. *)
let register username password =
  lwt users' = Eliom_reference.get users in
  try
    ignore (List.assoc username users');
    die E.Already_registered
  with Not_found ->
    Eliom_reference.set users
      ((username, Bcrypt.hash password) :: users')


(* Verify user identity and set session variable. *)
let login username password =
  let login = Eliom_reference.Volatile.get user in
  match login with
  | Some user ->
      die (E.Already_logged_in User.(user.id))
  | None ->
      lwt users' = Eliom_reference.get users in
      try
        if Bcrypt.verify password (List.assoc username users') then (
          Eliom_reference.Volatile.set user (Some { User.id = username });
          Lwt.return ()
        ) else (
          die E.Bad_credentials
        )
      with Not_found ->
        die E.Bad_credentials


(* Reset user session variable to logout. *)
let logout () =
  Eliom_reference.Volatile.unset user


(* Wrapper for services that require a login. *)
let user_service fn get post =
  let user = Eliom_reference.Volatile.get user in
  match user with
  | None ->
      die E.Not_logged_in
  | Some user ->
      fn user get post
