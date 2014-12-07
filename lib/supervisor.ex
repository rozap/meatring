defmodule Meatring.Supervisor do
  
  use Supervisor

  def start_link(options) do
    {pid, descriptor} = Exkad.Node.Gateway.build_node(
      options[:id],
      options[:desc],
      :http, 
      options[:bind]
    )
    Logger.debug("Node has been created with descriptor: #{descriptor}")
    {pid, descriptor}

  end


  defp child(children, mod, args, true), do: [worker(mod, args) | children]
end