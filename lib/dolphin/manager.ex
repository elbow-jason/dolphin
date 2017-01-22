defmodule Dolphin.Manager do

  @moduledoc """
  Dolphin.Queue manages the state of workers
  """

  defstruct [
    status:   :initialized,
    workers: [],
  ]

  defmacro __using__(opts) do
    quote do
      use GenServer

      @worker_module unquote(opts) |> Keyword.get(:worker_module)
      if is_nil(@worker_module) do
        raise "Dolphin.Manager requires a :worker_module with a `start_worker(name)` function"
      end

      # API
      def start_workers do
        GenServer.call(__MODULE__, :start_workers)
      end

      def stop_workers do
        GenServer.call(__MODULE__, :stop_workers)
      end

      def status do
        GenServer.call(__MODULE__, :status)
      end

      def running? do
        status() == :running
      end

      def workers do
        GenServer.call(__MODULE__, :workers)
      end

      def add_worker(name) do
        GenServer.call(__MODULE__, {:add_worker, name})
      end

      def remove_worker(name) do
        GenServer.call(__MODULE__, {:remove_worker, name})
      end

      # SERVER
      def start_link do
        GenServer.start_link(__MODULE__, %Dolphin.Manager{} , name: __MODULE__)
      end

      def handle_call(:start_workers, _from, %{status: :running} = state) do
        {:reply, :ok, state}
      end
      def handle_call(:start_workers, _from, state) do
        this = self()
        state
        |> Map.get(:workers)
        |> Enum.map(fn name ->
          send this, {:start_worker, name}
        end)
        {:reply, :ok, %{ state | status: :running }}
      end
      def handle_call(:workers, _from, state) do
        {:reply, state.workers, state}
      end
      def handle_call(:status, _from, state) do
        {:reply, state.status, state}
      end
      def handle_call({:add_worker, name}, _from, state) do
        workers = [ name | state.workers ]
        {:reply, {:added, name}, %{ state | workers: workers }}
      end
      def handle_call({:remove_worker, name}, _from, state) do
        workers =
          state.workers
          |> Enum.filter(fn w_name -> w_name != name end)
        {:reply, {:removed, name}, %{ state | workers: workers }}
      end
      def handle_call(:stop_workers, _from, state) do
        {:reply, :stopped, %{ state | status: :stopped }}
      end

      def handle_info({:start_worker, name}, state) do
        @worker_module.start_worker(name)
        {:noreply, state}
      end

    end
  end
end
