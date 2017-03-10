defmodule Drd.Application do
  @moduledoc false

  alias Drd.Telegram
  alias Drd.HackerNews

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      #worker(Telegram.Listener, []),
      worker(HackerNews.Listener, []),

      supervisor(Registry, [:unique, Registry.Conversations]),
      supervisor(Telegram.Conversation.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: Drd.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
