use Mix.Config

config :drd, [
  offset_file: "offset.drd",
  story_ids_file: "story_ids.drd"
]

import_config "#{Mix.env}.exs"
