defmodule TrafficDispatcher do
  @moduledoc false

  use GenServer

  @walker_light :walker
  @machine_light :machine

  @walker_min_red_light_time_secs = 5
  @walker_min_min_light_time_secs = 3

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.inspect("TrafficDispatcher.init")
    {:ok, :on} = TrafficLight.red_light_on(@walker_light)
    {:ok, :off} = TrafficLight.green_light_off(@walker_light)

    {:ok, :on} = TrafficLight.red_light_on(@machine_light)
    {:ok, :off} = TrafficLight.green_light_off(@machine_light)

    {
      :ok,
      %{
        status: %{
          machine: :green_light,
          walker: :red_light,
          is_walker_pushed: false
        }
      }
    }
  end

  def push_walker_button do
    GenServer.call(__MODULE__, :push_walker_button)
  end

  # Server

  def handle_call(:push_walker_button, _from, state) do
    IO.inspect({"TrafficDispatcher", state})

    # Статусы перекрестка
    # Горит зеленый автомобилям
    # Горит зеленый автомибилям и нажанат кнопка пешехода
    # Горит зеленый пешеходам

    # Cases
    # Если горит пешеходам зеленый, то ничего не делаем. По таймеру зеленый переключится на красный.
    #   Сбрасывем флаг нажатия кнопки, когда переключаемся на красный свет пешеходам.
    # Если горит красный пещеходам и флаг нажатия кнопки на выставлен, то запускаем таймер включения зеленого
    #   пешеходам. Рассчитываем время, сколько осталось гореть минимальное время. Если минимальное время
    #   горения прошло для зеленого света автомобилям, то включаем зеленый свет пешеходам сразу, без таймера

    # Важно
    # Добавить настраиваемый таймер для регулировки длмтельности горения сигнала светофора

    #machine_light_status = TrafficLight.status_lights(@machine_light)
    walker_light_status = TrafficLight.status_lights(@walker_light)

    case walker_light_status do
      %{red_light: {:on, red_light_time}} ->
        secs = Time.utc_now() - red_light_times1
        if secs < @walker_min_red_нонlight_time_secs do
          unless get_in(state, [:status, :is_walker_pushed]) do
            state = put_in(state, [:status, :is_walker_pushed], true)

            remaining_secs = @walker_min_red_light_time_secs - secs
            Process.send_after(self(), :walker_red_light_off, remaining_secs * 1000)
          end
        else
          GenServer.call(self(), :walker_red_light_off)

          Process.send_after(self(), :walker_red_light_on, @walker_min_min_light_time_secs * 1000)
        end
      _ ->
        IO.inspect({"Default case", state})
    end

    {:reply, :test, state |> IO.inspect({"New state", state})}
  end

  def handle_call(:walker_red_light_off, _from, state) do
    state = put_in(state, [:status, :is_walker_pushed], false)

    TrafficLight.red_light_on(@machine_light)
    TrafficLight.green_light_off(@machine_light)
    TrafficLight.red_light_off(@walker_light)
    TrafficLight.green_light_on(@walker_light)

    {:reply, :test, state}
  end

  def handle_call(:walker_red_light_on, _from, state) do
    state = put_in(state, [:status, :is_walker_pushed], false)

    TrafficLight.red_light_off(@machine_light)
    TrafficLight.green_light_on(@machine_light)
    TrafficLight.red_light_on(@walker_light)
    TrafficLight.green_light_off(@walker_light)

    {:reply, :test, state}
  end

  # private

  # TODO надо ли?
  defp lights_turning(:red_light_on, :green_light_off) do
    %{red_light: {:on, Time.utc_now()}, green_light: {:off, Time.utc_now()}}
  end
  defp lights_turning(:red_light_off, :green_light_on) do
    %{red_light: {:off, Time.utc_now()}, green_light: {:on, Time.utc_now()}}
  end
  defp lights_turning(red_light, green_light) do
    IO.inspect({"Arguments", red_light, green_light})
    raise ArgumentError
  end
end
