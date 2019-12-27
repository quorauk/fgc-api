defmodule Fgc.UserManager.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :fgc,
    error_handler: Fgc.UserManager.ErrorHandler,
    module: Fgc.UserManager.Guardian

  plug :fetch_session
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
