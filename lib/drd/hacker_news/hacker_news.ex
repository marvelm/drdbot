defmodule Drd.HackerNews do
  defp fetch!(url) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    Poison.decode! body
  end

  def topstories!() do
    url = "https://hacker-news.firebaseio.com/v0/topstories.json"
    fetch!(url)
  end

  def item!(id) do
    url = "https://hacker-news.firebaseio.com/v0/item/#{id}.json"
    fetch!(url)
  end

  def askstories!() do
    url = "https://hacker-news.firebaseio.com/v0/askstories.json"
    fetch!(url)
  end
end
