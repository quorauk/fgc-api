defmodule Fgc.Repo do
  use Ecto.Repo,
    otp_app: :fgc,
    adapter: Ecto.Adapters.Postgres
end
