defmodule Drd.Elasticsearch do
  defp url(path) do
    "http://localhost:9200#{path}"
  end

  defp create_index!(index, mappings) do
    body = %{"mappings" => mappings}

    HTTPoison.put!(
      url("/#{index}"),
      Poison.encode!(body),
      [{"Content-Type", "application/json"}])
  end

  @text %{"type" => "text"}
  @long %{"type" => "long"}
  @array %{"type" => "array"}
  @date %{"type" => "date"}

  @subscriptions "subscriptions"
  @hn_stories "hn_stories"

  def create_indices!() do
    create_index!(@subscriptions, %{
      "subscription" => %{
        "properties" => %{
          "user_id" => @long,
          "first_name" => @text,
          "last_name" => @text,
          "username" => @text,
          "keywords" => @array
        }
      }
    })

    create_index!(@hn_stories, %{
      "story" => %{
        "properties" => %{
          "title" => @text,
          "url" => @text,
          "id" => @long,
          "submitter" => @text,
          "submitted_at" => @date
        }
      }
    })
  end

  def add_hn_story!(story) do
    body = %{
      "title" => story["title"],
      "url" => story["url"],
      "id" => story["id"],
      "submitter" => story["by"],
      "submitted_at" => story["time"]
    }

    HTTPoison.post!(
      url("/#{@hn_stories}/story"),
      Poison.encode!(body),
      [{"Content-Type", "application/json"}])
  end
end
