defmodule Drd.HackerNews.Listener do
  use GenServer
  require Logger

  alias Drd.HackerNews

  @doc """
  Initializes the worker with an update offset of 0.
  """
  def start_link do
    GenServer.start_link(__MODULE__, MapSet.new)
  end

  def init(last_story_ids) do
    send(self(), :fetch_updates)
    {:ok, last_story_ids}
  end

  def handle_info(:fetch_updates, last_story_ids) do
    send self(), :fetch_updates

    story_ids = MapSet.new(HackerNews.topstories!())
    new_story_ids = MapSet.difference(story_ids, last_story_ids)

    stories = Enum.map(new_story_ids, &(HackerNews.item!(&1)))
    broadcast_stories!(stories)

    {:noreply, new_story_ids}
  end

  def broadcast_stories!(_stories) do
  end
end
