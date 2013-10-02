install Library ".DEFAULT" [
  (* Target *)
  Name		"webservice";
  Description	"Test webservice";

  (* Sources *)
  Modules [
    "Json_registration";
    "UserService";
    "Login";
  ];

  (* Library dependencies *)
  OCamlRequires [
    "eliom.server";
    "js_of_ocaml.deriving.syntax";
    "lwt.syntax";
    "safepass";
  ];

  (* Camlp4 *)
  Flags [
    "json_registration.ml",	"-syntax camlp4o";
    "userService.ml",		"-syntax camlp4o";
    "login.ml",			"-syntax camlp4o";
  ];

  Var ("COMPILEFLAGS", "$(COMPILEFLAGS) -thread");
  Var ("LINKFLAGS", "$(LINKFLAGS) -thread");
]
