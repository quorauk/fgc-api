defmodule Fgc.UserManager.UserManager do
  import Ecto.Query, only: [from: 2]

  alias Argon2
  alias Fgc.Repo
  alias Fgc.UserManager.{User, Guardian}

  def authenticate_user(username, plain_text_password) do
    query = from u in User, where: u.username == ^username

    case Repo.one(query) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      user ->
        if Argon2.verify_pass(plain_text_password, user.password) do
          {:ok, token, _} = Guardian.encode_and_sign(user)
          {:ok, user, token}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def token_for_user(user) do
    {:ok, token, _} = Guardian.encode_and_sign(user)
    {:ok, user, token}
  end
end
