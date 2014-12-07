defmodule Meatring do
  require Logger

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
    IO.inspect parsed
    case parsed do
      {[help: true], _, _} -> :help
      {options, _, _} -> Enum.into(options, %{})
      _ -> :help
    end
  end


  defp build(:help), do: :help

  defp build(options) do
    Meatring.Supervisor.start_link options
  end


  defp process(:help) do
    IO.puts """
      Usage:
        meatring --bind <ip:port to bind to> --seed_id <seed_id> --seed_location <seed_location>

      Options:
        -h, [--help]            # Show this help message and quit.
        -b, [--bind]            # Bind to address [localhost:8080]
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



  def start(_type, args) do
    args |> parse_args |> process |> build
  end

end
