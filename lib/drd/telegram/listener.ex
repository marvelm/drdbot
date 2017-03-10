defmodule Drd.Telegram.Listener do
  use GenServer
  require Logger

  alias Drd.Telegram

  @doc """
  Initializes the worker with an update offset of 0.
  """
  def start_link do
    GenServer.start_link(__MODULE__, 0)
  end

  def init(offset) do
    send(self(), :fetch_updates)
    {:ok, offset}
  end

  def handle_info(:fetch_updates, offset) do
    send self(), :fetch_updates

    updates = Telegram.get_updates! offset
    Logger.debug "updates #{inspect updates}"

    broadcast_updates(updates)
    save_offset(offset)

    last_update = List.last updates
    next_offset =
      case last_update do
        nil -> offset
        _ -> last_update["update_id"] + 1
      end

    {:noreply, next_offset}
  end

  defp broadcast_updates(updates) do
    Enum.each(updates, fn update ->
      case update do
        %{"message" => %{"from" => %{"id" => sender_id}}} ->
          send_update(sender_id, update)
        _ ->
      end
    end)
  end

  defp send_update(sender_id, update) do
    conversation =
      case Registry.lookup(Registry.Conversations, sender_id) do
        [] ->
          {:ok, pid} = Supervisor.start_child(Telegram.Conversation.Supervisor, [[sender_id], []])
          pid
        [{pid, _value}] -> pid
      end

    GenServer.cast(conversation, {:update, update})
  end

  def save_offset(offset) do
  end
end
