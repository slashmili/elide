defmodule Elide.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "rooms:*", Elide.RoomChannel
  channel "home:page", Elide.HomeChannel
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
