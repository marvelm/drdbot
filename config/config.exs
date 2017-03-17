use Mix.Config

config :drd, [
  offset_file: "offset.drd",
  story_ids_file: "story_ids.drd",
  hn_update_interval: 60_000
]

import_config "#{Mix.env}.exs"
