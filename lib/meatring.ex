defmodule Meatring do
  use Application
  require Logger

  def start(type, args) do
    Logger.warn("w e l c o m e  t o  M E A T R I N G")
    Meatring.Supervisor.start_link(args)
  end

end
