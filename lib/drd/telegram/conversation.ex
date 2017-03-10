defmodule Drd.Telegram.Conversation do
  use GenServer
  require Logger

  alias Drd.Telegram

  def start_link(sender_id, opts \\ []) do
    GenServer.start_link(__MODULE__, sender_id, opts)
  end

  def init(sender_id) do
    Registry.register(Registry.Conversations, sender_id, nil)
    updates = []
    {:ok, updates}
  end

  def handle_cast({:update, update}, updates) do
    case update do
      %{"message" => msg} -> handle_msg(msg)
    end

    {:noreply, [update] ++ updates}
  end

  def handle_msg(%{"text" => text}) do
    IO.puts text
  end
end
