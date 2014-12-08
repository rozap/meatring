
defmodule Meatring.Plug do
  import Plug.Conn


  defmodule API do
    use Plug.Router
    import Plug.Conn
    alias Exkad.Node.Gateway, as: DHT
    plug Plug.Static, at: "/static", from: :meatring
    plug :match
    plug :dispatch

    @index "../priv/templates/index.html"

    def as_json({:ok, res}), do: as_json(res)
    def as_json({:value, res}), do: as_json(res)

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
        DHT.put(conn.plug_options.node, data, meta) |> finish(conn, 201)
      rescue
        err -> 
          IO.inspect err
          finish(%{"error" => "you need to PUT a dict with data and meta objects"}, conn, 400)
      end
    end


    get "/api/item/:key" do
      DHT.get(conn.plug_options.node, key) |> finish(conn)
    end

    get "/api/search/:term" do
      DHT.search(conn.plug_options.node, term) 
        |> Enum.map(fn key -> 
          IO.puts "Getting #{key}"

          data = case DHT.get(conn.plug_options.node, key) do
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




  def init(options) do
    Enum.into(options, %{})
  end

  def call(conn, options) do
    Map.put(conn, :plug_options, options) |> API.call(options)
  end
end

