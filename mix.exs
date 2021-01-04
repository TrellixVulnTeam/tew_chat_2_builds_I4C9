defmodule TewChat2.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      version: "0.1.0",
      elixir: "~> 1.9",
      releases: [
        #Used to be tew_chat_2:, now it's prod:
        prod: [
          applications: [
            db: :permanent,
            phxapp: :permanent
          ]
        ]
      ]
    ]
  end
  #Hey
  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end
end
