defmodule FgcWeb.SessionController do
  use FgcWeb, :controller


  alias Fgc.{UserManager, UserManager.User, UserManager.Guardian}

  def new(conn, _) do
    changeset = UserManager.change_user(%User{})
    maybe_user = Guardian.Plug.current_resource(conn)

    if maybe_user do
      redirect(conn, to: "/protected")
    else
      render(conn, "new.html", changeset: changeset, action: Routes.session_path(conn, :login))
    end
  end

  def me(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    json(conn, %{username: user.username})
  end

  def validate_login(conn, _) do
    conn
    |> send_resp(201, "")
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    UserManager.UserManager.authenticate_user(username, password)
    |> login_reply(conn)
  end

  def json_login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    UserManager.UserManager.authenticate_user(username, password)
    |> json_login_reply(conn)
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/login")
  end

  def webhook_token(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    {:ok, _jwt, token} = UserManager.UserManager.token_for_user(user)
    conn
    |> json(token)
  end

  defp json_login_reply({:ok, jwt, token}, conn) do
    conn
    |> Guardian.Plug.sign_in(jwt)
    |> json(token)
  end


  def json_logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> text("ok")
  end

  defp login_reply({:ok, user, _}, conn) do
    conn
    |> put_flash(:info, "Welcome back!")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/protected")
  end

  defp login_reply({:error, reason}, conn) do
    conn
    |> put_flash(:error, to_string(reason))
    |> new(%{})
  end
end
