defmodule Meatring.Supervisor do
  
  use Supervisor
  require Logger

  def start_link(options) do
    {pid, descriptor} = Exkad.Node.Gateway.build_node(
      options[:id],
      options[:desc],
      :http, 
      options[:bind]
    )


    Plug.Adapters.Cowboy.http(Meatring.Plug, [node: pid], port: options.server_port)

    Logger.debug("Node #{inspect pid} has been created with descriptor: #{descriptor}")
    
    {pid, descriptor}

  end
end