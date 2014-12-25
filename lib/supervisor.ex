defmodule Meatring.Supervisor do
  
  use Supervisor
  require Logger

  defmodule NodeWrap do
    use GenServer
    def start_link(options) do
      GenServer.start_link(__MODULE__, options)
    end

    def init(options) do
      Logger.info("Starting node with id #{options[:id]}")
      {pid, descriptor} = Exkad.Node.Gateway.build_node(
        options[:id],
        options[:seed],
        :http, 
        options[:bind]
      )

      Process.register(pid, :exkad_node)
      {:ok, descriptor}
    end

  end



  def start_link(options) do
    Supervisor.start_link(__MODULE__, options)
  end

  def init(options) do

    
    Logger.info("init with #{inspect options}")
    # Logger.debug("Node #{inspect pid} has been created with descriptor: #{descriptor}")
    
    # {pid, descriptor}
    children = [
      worker(NodeWrap, [options])
    ]

    plug = Meatring.Plug.API
    opts = []

    opts = plug.init(opts)

    # {'_', [
    #   {"/", cowboy_static, {priv_file, websocket, "index.html"}},
    #   {"/websocket", ws_handler, []},
    #   {"/static/[...]", cowboy_static, {priv_dir, websocket, "static"}}
    # ]}

    dispatch = [
      {:_, 
        [ 
          {"/websocket", Meatring.Websocket, opts},
          {:_, Plug.Adapters.Cowboy.Handler, {plug, opts}}
        ]
      }
    ]

    Plug.Adapters.Cowboy.http(plug, opts, [
      port: options.server_port, 
      dispatch: dispatch
    ])

    {:ok, opts}


    supervise(children, strategy: :one_for_one)
  end


end