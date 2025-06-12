open Letters

let ( let* ) = Lwt.bind

let get_mailtrap_account_details () =
  let open Yojson.Basic.Util in
  (* see the README.md how to generate the account file and the path
     * below is relative to the location of the executable under _build
  *)
  let json = Yojson.Basic.from_file "../../../mailtrap_account.json" in
  let username = json |> member "username" |> to_string in
  let password = json |> member "password" |> to_string in
  let hostname = json |> member "hostname" |> to_string in
  let port = json |> member "port" |> to_int in
  let with_starttls = json |> member "secure" |> to_bool |> not in
  let mechanism = Sendmail.PLAIN in
  Config.create ~mechanism ~username ~password ~hostname ~with_starttls ()
  |> Config.set_port (Some port)
  |> Lwt.return
;;

let test_multiple_emails config _ () =
  let n_emails = 10000 in
  let create n =
    let subject = Format.asprintf "(%5d) Multiple email test" n in
    let sender = "multi@example.com" in
    let recipients = [ To "tester@example.com" ] in
    let text = {| This is a test email with multiple recipients. Please ignore it.|} in
    let html =
      {|
<p>This is a test email with multiple recipients.</p>
<p>Please ignore it.</p>
|}
    in
    let mail =
      create_email ~from:sender ~recipients ~subject ~body:(Mixed (text, html, None)) ()
    in
    match mail with
    | Ok message -> send ~config ~sender ~recipients ~message |> Lwt.map (fun () -> None)
    | Error reason -> Lwt.return_some reason
  in
  let* errors = List.init n_emails (fun i -> i + 1) |> Lwt_list.filter_map_s create in
  Alcotest.(check int) "No errors when sending emails" 0 (List.length errors);
  if errors <> []
  then Alcotest.failf "Errors occurred:\n%s" (String.concat "\n" errors)
  else Lwt.return_unit
;;

let create_test ~mailtrap_conf_with_ca_detect () =
  ( "use mailtrap, test a lot of emails"
  , [ Alcotest_lwt.test_case
        "Send multiple emails"
        `Slow
        (test_multiple_emails mailtrap_conf_with_ca_detect)
    ] )
;;

let () =
  Lwt_main.run
    (let* mailtrap_conf_with_ca_detect = get_mailtrap_account_details () in
     Alcotest_lwt.run "SMTP client" [ create_test ~mailtrap_conf_with_ca_detect () ])
;;
