defmodule Bubbles.Repo do
  use Ecto.Repo,
    otp_app: :bubbles,
    adapter: Ecto.Adapters.Postgres
end
