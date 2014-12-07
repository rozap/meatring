defmodule Meatring do
  use Application


  def start(type, args) do
    IO.puts "Starting app! #{inspect type} #{inspect args}"
    Meatring.Supervisor.start_link(args)
  end

end
