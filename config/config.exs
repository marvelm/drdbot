use Mix.Config

config :drd, [
  offset_file: "offset.drd"
]

import_config "#{Mix.env}.exs"
