defmodule Meatring.Supervisor do
  
  use Supervisor
  require Logger

  defmodule NodeWrap do
    use GenServer
    def start_link(options) do
      GenServer.start_link(__MODULE__, options)
    end

    def init(options) do
      {pid, descriptor} = Exkad.Node.Gateway.build_node(
        options[:id],
        options[:seed],
        :http, 
        options[:bind]
      )

      Process.register(pid, :exkad_node)
      Logger.info("Node #{inspect pid} has been created with id: #{descriptor.id} and location: #{descriptor.loc}")
      {:ok, descriptor}
    end

  end

  def start_link(options) do
    Supervisor.start_link(__MODULE__, options, name: Meatring.Supervisor)
  end

  def init(options) do
    children = [
      worker(NodeWrap, [options])
    ]

    plug = Meatring.Plug.API
    opts = plug.init([])

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

    supervise(children, strategy: :one_for_one)
  end


end