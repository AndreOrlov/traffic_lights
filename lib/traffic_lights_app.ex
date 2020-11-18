defmodule TrafficLightsApp do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [
        Supervisor.child_spec({TrafficLight, %{name: :walker}}, [id: :walker]),
        Supervisor.child_spec({TrafficLight, %{name: :machine}}, [id: :machine]),
        TrafficDispatcher
      ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end