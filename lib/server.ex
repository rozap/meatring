
defmodule Meatring.Plug.API do

  use Plug.Router
  import Plug.Conn
  alias Exkad.Node.Gateway, as: DHT
  require Logger
  plug Plug.Static, at: "/static", from: :meatring
  plug :match
  plug :dispatch

  @index "../priv/templates/index.html"

  def as_json({:ok, res}), do: as_json(res)
  def as_json({:value, res}), do: as_json(res)
  def as_json({:error, err}), do: as_json(%{error: err})

  def as_json(r) do
    Poison.encode!(r)
  end


  def finish(res, conn, status \\ 200) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, as_json(res))
  end


  post "/api/item" do
    {:ok, body, conn} = read_body(conn) 
    js = body |> Poison.decode!
    try do
      %{"meta" => meta, "data" => data} = js
      Logger.info("Posting message with metadata #{inspect meta}")
      DHT.put(:exkad_node, data, meta) |> finish(conn, 201)
    rescue
      err -> 
        IO.inspect err
        finish(%{"error" => "you need to PUT a dict with data and meta objects"}, conn, 400)
    end
  end


  get "/api/item/:key" do
    DHT.get(:exkad_node, key) |> finish(conn)
  end

  get "/api/search/:term" do
    DHT.search(:exkad_node, term) 
      |> Enum.map(fn key -> 

        data = case DHT.get(:exkad_node, key) do
          {:value, {:ok, res}} ->  res
          {:error, :not_found} ->  "not found"
        end

        %{
          key: key,
          data: data
        }
      end)
      |> finish(conn, 200)
  end

  get "/" do
    idx = Path.join([__DIR__, @index])
      |> Path.expand
      |> EEx.eval_file
    send_resp(conn, 200, idx)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

end

