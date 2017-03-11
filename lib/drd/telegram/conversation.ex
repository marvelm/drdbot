defmodule Drd.Telegram.Conversation do
  use GenServer
  require Logger

  alias Drd.Telegram

  def start_link(chat_id, opts \\ []) do
    Logger.debug "created-conversation #{inspect chat_id}"
    GenServer.start_link(__MODULE__, chat_id, opts)
  end

  def init(chat_id) do
    Registry.register(Registry.Conversations, chat_id, nil)
    updates = []
    {:ok, %{
      updates: updates,
      chat_id: chat_id,
      adding_keywords?: false,
      removing_keywords?: false
    }}
  end

  def handle_cast({:update, update}, state) do
    state = case update do
      %{"message" => msg} -> handle_msg!(msg, state)
    end
    {:noreply, %{state | updates: [update] ++ state.updates}}
  end

  defp handle_msg!(%{"text" => text}, state) do
    to = state.chat_id

    case String.downcase text do
      "/start" ->
        Telegram.send_message!(to,
          "I will send you a daily list of all posts on HN which match certain keywords.")
        default_reply!(to)

        %{state | adding_keywords?: false, removing_keywords?: false}

      "add keywords" ->
        Telegram.send_message!(to,
          """
          Please enter the keywords you wish to monitor.
          Enter /start at any time to return to the main menu.
          """,
          %{"reply_markup" => %{"remove_keyboard" => true}}
        )
        %{state | adding_keywords?: true}

      "remove keywords" ->
        Telegram.send_message!(to,
          """
          Please enter the keywords you wish to stop monitoring
          Enter /start at any time to return to the main menu.
          """,
          %{"reply_markup" => %{"remove_keyboard" => true}}
        )
        %{state | removing_keywords?: true}

      text ->
        cond do
          state.adding_keywords? -> Telegram.send_message!(to, "Added '#{text}'")
          state.removing_keywords? -> Telegram.send_message!(to, "Removed '#{text}'")
          true -> default_reply!(to)
        end

        state
    end
  end

  defp default_reply!(to) do
    reply_keyboard = %{
      "keyboard" => [["Add keywords"], ["Remove keywords"]],
      "one_time_keyboard" => true
    }

    Telegram.send_message!(to, "You may either add or remove keywords", %{"reply_markup" => reply_keyboard})
  end
end
