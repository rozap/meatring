defmodule Meatring do
  use Application


  def start(type, args) do
    IO.puts "Starting..? #{inspect type} #{inspect args}"
    Meatring.Supervisor.start_link(args)
  end

end
