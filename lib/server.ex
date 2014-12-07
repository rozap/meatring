
defmodule Meatring.Plug do
  import Plug.Conn
  alias Exkad.Node.Gateway, as: DHT

  defmodule API do
    use Plug.Router
    import Plug.Conn
    plug Plug.Static, at: "/static", from: :meatring
    plug :match
    plug :dispatch

    def as_json({:ok, res}), do: as_json(%{"ok" => res})
    def as_json({:value, res}), do: as_json(res)

    def as_json(r) do
      Poison.encode!(r)
    end


    def finish(res, conn, status \\ 200) do
      conn
        |> put_resp_content_type("application/json")
        |> send_resp(status, as_json(res))
    end


    put "/api/item" do
      {:ok, body, conn} = read_body(conn) 
      js = body |> Poison.decode!
      try do
        %{"meta" => meta, "data" => data} = js
        DHT.put(conn.plug_options.node, data, meta) |> finish(conn, 201)
      rescue
        err -> 
          IO.inspect err
          finish(%{"error" => "you need to PUT a dict with data and meta objects"}, conn, 400)
      end
    end


    get "/api/item/:key" do
      [_, _, key] = conn.path_info
      IO.puts "GEt #{key}"
      DHT.get(conn.plug_options.node, key) |> finish(conn)
    end

    get "/api/search/:term" do
      [_, _, term] = conn.path_info
      IO.inspect "Searching for #{term}"
      DHT.search(conn.plug_options.node, term) |> finish(conn, 200)
    end

    match _ do
      send_resp(conn, 404, "not found")
    end
  end




  def init(options) do
    IO.inspect "Started plug with #{inspect options}"
    Enum.into(options, %{})
  end

  def call(conn, options) do
    Map.put(conn, :plug_options, options) |> API.call(options)
  end
end

