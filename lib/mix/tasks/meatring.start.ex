defmodule Mix.Tasks.Meatring.Start do
  use Mix.Task

  @shortdoc "Starts application"

  @default_bind "http://localhost:8080"
  @default_server_port 8081

  defp switches do
    [
      help: :boolean
    ]
  end


  defp aliases do
    [
      h: :help,
      b: :bind,
      sid: :seed_id, 
      loc: :seed_location
    ]
  end


  defp parse_args(args) do
    parsed = OptionParser.parse(args, switches: switches, aliases: aliases)
    case parsed do
      {[help: true], _, _} -> :help
      {options, _, _} -> Enum.into(options, %{})
      _ -> :help
    end
  end


  defp defaults(:help), do: :help
  defp defaults(args) do
    Enum.into(args, %{
      bind: @default_bind,
      server_port: @default_server_port
    })
  end


  defp process(:help) do
    IO.puts """
      Usage:
        meatring --bind <ip:port to bind to> --seed_id <seed_id> --seed_location <seed_location>

      Options:
        -h, [--help]            # Show this help message and quit.
        -b, [--bind]            # Bind to address [#{@default_bind}]
        -s, [--server_port]     # bind server address [#{@default_server_port}]
        -sid, [--seed_id]       # id of node already in network to attach to
        -loc [--seed_location]  # location of that node in the network
        -id, [--id]             # your node's id. if you haven't joined, it will be generated for you

      Description:
        m e a t s p a c e s 
    """
    :help
  end

  defp process(%{seed_id: id, seed_location: loc} = options) do
    desc = %Exkad.Node.Descriptor{id: loc, loc: loc}
    
    options
      |> Dict.drop([:seed_id, :seed_location])
      |> Dict.put(:descriptor, desc)
  end


  defp process(options) do
    options
  end



  def run(args) do
    args = args |> parse_args |> defaults |> process
    case args do
      :help -> :help
      args -> 
        #why the fuck isn't this working...
        # Mix.Task.run("app.start", args)
        Meatring.Supervisor.start_link(args)
        :timer.sleep(:infinity)
    end
  end

end