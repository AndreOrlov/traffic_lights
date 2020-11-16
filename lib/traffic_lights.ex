defmodule TrafficLights do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{status: :red_light_walker}, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts}
  end

  def push_walker_button do
    GenServer.call(__MODULE__, :push_walker_button)
  end

  def red_light_walker_on do
    GenServer.call(__MODULE__, :red_light_walker_on)
  end

  def red_light_walker_off do
    GenServer.call(__MODULE__, :red_light_walker_off)
  end

  def status_light_walker do
    GenServer.call(__MODULE__, :status_light_walker)
  end

  # Server

  def handle_call(:push_walker_button, _from, state) do
    # TODO доделать задержку
    IO.inspect({"push_walker_button", %{state | status: :green_lignt_walker}})
    {:reply, %{status: :green_lignt_walker}, %{state | status: :green_lignt_walker}}
  end

  def handle_call(:red_light_walker_on, _from, state) do
    IO.inspect({"red_light_walker_on", %{state | status: :red_light_walker}})
    {:reply, %{status: :red_light_walker}, %{state | status: :red_light_walker}}
  end

  def handle_call(:red_light_walker_off, _from, state) do
    IO.inspect({"red_light_walker_off", %{state | status: :green_lignt_walker}})
    {:reply, %{status: :green_lignt_walker}, %{state | status: :green_lignt_walker}}
  end

  def handle_call(:status_light_walker, _from, state) do
    IO.inspect({"status", state})
    {:reply, state, state}
  end
end