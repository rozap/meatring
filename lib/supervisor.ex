defmodule Meatring.Supervisor do
  
  use Supervisor
  require Logger

  defmodule NodeWrap do
    use GenServer
    def start_link(_) do
      GenServer.start_link(__MODULE__, [])
    end

    defp make_seed do
      id = Application.get_env(:meatring, :seed_id, nil)
      loc = Application.get_env(:meatring, :seed_location, nil)
      if id != nil and loc != nil do
        %Exkad.Node.Descriptor{id: id, loc: loc}
      else
        nil
      end
    end

    def init(_) do
      {pid, descriptor} = Exkad.Node.Gateway.build_node(
        Application.get_env(:meatring, :id, nil),
        make_seed,
        :http, 
        Application.get_env(:meatring, :bind, "http://localhost:8080")
      )

      Process.register(pid, :exkad_node)
      Logger.info("Node #{inspect pid} has been created with id: #{descriptor.id} and location: #{descriptor.loc}")
      {:ok, descriptor}
    end

  end

  def start_link(options) do
    Supervisor.start_link(__MODULE__, options, name: Meatring.Supervisor)
  end

  def init(_) do
    children = [
      worker(__MODULE__.NodeWrap, [[:foo]])
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
      port: Application.get_env(:meatring, :server_port, 8081), 
      dispatch: dispatch
    ])

    supervise(children, strategy: :one_for_one)
  end


end