[
  import_deps: [:ecto, :ecto_sql, :phoenix, :surface],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,test}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs",
    "{lib,test}/**/*.sface"
  ]
]
