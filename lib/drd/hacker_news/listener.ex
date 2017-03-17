defmodule Drd.HackerNews.Listener do
  use GenServer
  require Logger

  alias Drd.HackerNews
  alias Drd.Elasticsearch

  @interval Application.get_env(:drd, :hn_update_interval)

  @doc """
  Initializes the worker with an update offset of 0.
  """
  def start_link do
    story_ids_file = Application.get_env(:drd, :story_ids_file)
    story_ids = case File.read(story_ids_file) do
      {:ok, raw} -> Poison.decode!(raw)
      _ -> []
    end

    GenServer.start_link(__MODULE__, MapSet.new(story_ids))
  end

  def init(last_story_ids) do
    send(self(), :fetch_updates)
    {:ok, last_story_ids}
  end

  def handle_info(:fetch_updates, last_story_ids) do
    Process.send_after(self(), :fetch_updates, @interval)

    story_ids = MapSet.new(HackerNews.topstories!())
    new_story_ids = MapSet.difference(story_ids, last_story_ids)

    new_stories = Enum.map(new_story_ids, &(HackerNews.item!(&1)))
    Enum.each(new_stories, &(Elasticsearch.add_hn_story!(&1)))

    save_story_ids_file!(new_story_ids)
    {:noreply, new_story_ids}
  end

  def save_story_ids_file!(story_ids) do
    story_ids_file = Application.get_env(:drd, :story_ids_file)
    File.write!(story_ids_file, Poison.encode!(story_ids))
  end
end
