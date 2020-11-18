defmodule TrafficLight do
  @moduledoc false

  use GenServer

  def start_link(%{name: name} = opts) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(_opts) do
    IO.inspect("TrafficLight.init")

    state =
      %{
        red_light: {:off, Time.uts_now()},
        green_light: {:off, Time.uts_now()}
      }

    {:ok, state}
  end

  def red_light_on(name) do
    GenServer.call(name, :red_light_on)
  end

  def red_light_off(name) do
    GenServer.call(name, :red_light_off)
  end

  def green_light_on(name) do
    GenServer.call(name, :green_light_on)
  end

  def green_light_off(name) do
    GenServer.call(name, :green_light_off)
  end

  def status_lights(name) do
    GenServer.call(name, :status_lights)
  end

  # Server

  def handle_call(:red_light_on, _from, state) do
    IO.inspect("red_light_on")

    state = %{state | red_light: {:on, Time.utc_now()}
    {:reply, Map.fetch(state, :red_light), state}
  end

  def handle_call(:red_light_off, _from, state) do
    IO.inspect("red_light_off")

    state = %{state | red_light: {:off, Time.utc_now()}}
    {:reply, Map.fetch(state, :red_light), state}
  end

  def handle_call(:green_light_on, _from, state) do
    IO.inspect("green_light_on")

    state = %{state | green_light: {:on, Time.utc_now()}}
    {:reply, Map.fetch(state, :green_light), state}
  end

  def handle_call(:green_light_off, _from, state) do
    IO.inspect("green_light_off")

    state = %{state | green_light: {:off, Time.utc_now()}}
    {:reply, Map.fetch(state, :green_light), state}
  end

  def handle_call(:status_lights, _from, state) do
    IO.inspect("status_lights")

    {:reply, Map.take(state, [:red_light, :green_light]), state}
  end
end