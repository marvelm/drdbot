defmodule Drd.Telegram.Listener do
  use GenServer
  require Logger

  alias Drd.Telegram

  @doc """
  Initializes the worker with an update offset of 0.
  """
  def start_link do
    offset = read_offset_file() || 0
    Logger.info "starting-offset #{offset}"
    GenServer.start_link(__MODULE__, offset)
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
    save_offset_file!(offset)

    next_offset =
      case List.last updates do
        nil -> offset
        last_update -> last_update["update_id"] + 1
      end

    {:noreply, next_offset}
  end

  defp broadcast_updates(updates) do
    Enum.each(updates, fn update ->
      case update do
        %{"message" => %{"chat" => %{"id" => chat_id}}} ->
          send_update(chat_id, update)
        _ ->
          Logger.info "unknown-update-type #{inspect update}"
      end
    end)
  end

  defp send_update(chat_id, update) do
    conversation =
      case Registry.lookup(Registry.Conversations, chat_id) do
        [] ->
          {:ok, pid} = Supervisor.start_child(Telegram.Conversation.Supervisor, [chat_id, []])
          pid
        [{pid, _value}] -> pid
      end

    GenServer.cast(conversation, {:update, update})
  end

  defp save_offset_file!(offset) do
    offset_file = Application.get_env(:drd, :offset_file)
    File.write!(offset_file, "#{offset}")
  end

  defp read_offset_file() do
    offset_file = Application.get_env(:drd, :offset_file)
    case File.read(offset_file) do
      {:ok, raw} ->
        {offset, _} = Integer.parse(raw)
        offset
      _ -> nil
    end
  end
end
