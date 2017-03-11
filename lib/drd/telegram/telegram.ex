defmodule Drd.Telegram do
  require Logger

  def token do
    Application.get_env(:drd, :token)
  end

  defp url(path) do
   "https://api.telegram.org/bot#{token()}#{path}"
  end

  defp post!(path, body) do
    HTTPoison.post!(url(path),
                    Poison.encode!(body),
                    [{"Content-Type", "application/json"}])
  end

  def send_message!(to, text, override \\ %{}) do
    Logger.debug "message-override #{inspect override}"
    message = Map.merge(%{"chat_id" => to,
                          "text" => text,
                          "parse_mode" => "HTML"}, override)
    Logger.debug "sending-message #{inspect message}"
    post!("/sendMessage", message)
  end

  def get_updates!(offset \\ 0, timeout \\ 4) do
    Logger.debug "Fetching updates"

    %HTTPoison.Response{body: body} = HTTPoison.get!(
      url("/getUpdates?offset=#{offset}&timeout=#{timeout}"),
      [recv_timeout: 15000, timeout: 15000])

    json = Poison.decode! body
    json["result"]
  end
end
