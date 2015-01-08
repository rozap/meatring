defmodule Meatring.Websocket do

  alias Exkad.Node.Gateway, as: DHT
  @behaviour :cowboy_websocket_handler
  require Logger
  alias :cowboy_req, as: Request

  def init({:tcp, :http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  defp get_key(req) do
    {_, key, _} = Request.parse_header("sec-websocket-key", req, :nothing)
    key
  end

  def websocket_init(_transport_name, req, opts) do
    Logger.info("ws init in #{inspect self}")
    {:ok, req, %{}}
  end

  def websocket_handle({:text, "watch:" <> term}, req, state) do
    Logger.info("#{inspect self} is watching #{term}")
    owner = self
    DHT.watch(:exkad_node, term, fn(term) -> 
      Logger.info("Dispatch from #{inspect owner} is #{term}")
      # send(owner, {:change, get_key(req), term})
    end)
    {:reply, {:text, "ok"}, req, state}
  end

  #echo everything else
  def websocket_handle({:text, msg}, req, state) do
    {:reply, {:text, msg}, req, state}
  end


  def websocket_info({:change, key, term}, req, state) do
    case get_key(req) do
      ^key -> 
          msg = Poison.encode!(%{event: "term.change", term: term})
          Logger.info("#{inspect self} Received watch notification for #{term} ----> #{msg}")
          {:reply, {:text, msg}, req, state}
      _ -> {:ok, req, state}
    end
  end

  def websocket_info(info, req, state) do
    Logger.info("Other info #{inspect info}")
    {:ok, req, state}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end