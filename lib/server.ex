defmodule Meatring.Plug do
  use Plug.Builder

  plug Plug.Static, at: "/static", from: :meatring
  plug :not_found

  def not_found(conn, _) do
    Plug.Conn.send_resp(conn, 404, "not found")
  end
end