defmodule Meatring.Websocket do

  alias Exkad.Node.Gateway, as: DHT
  @behaviour :cowboy_websocket_handler
  require Logger
  alias :cowboy_req, as: Request

  def init({:tcp, :http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_transport_name, req, opts) do
    Logger.info("ws init in #{inspect self}")
    {:ok, req, %{}}
  end

  def websocket_handle({:text, "watch:" <> term}, req, state) do
    Logger.info("#{inspect self} is watching #{term}")
    owner = self
    DHT.watch(:exkad_node, term)
    {:reply, {:text, "ok"}, req, state}
  end

  #echo everything else
  def websocket_handle({:text, msg}, req, state) do
    {:reply, {:text, msg}, req, state}
  end


  def websocket_info({:change, term}, req, state) do
    msg = Poison.encode!(%{event: "term.change", term: term})
    Logger.info("#{inspect self} Received watch notification for #{term} ----> #{msg}")
    {:reply, {:text, msg}, req, state}
  end

  def websocket_info(info, req, state) do
    Logger.info("Other info #{inspect info}")
    {:ok, req, state}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end