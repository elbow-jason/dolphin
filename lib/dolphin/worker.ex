defmodule Dolphin.Worker do
  defstruct [
    name: nil,
  ]

  defmacro __using__(opts) do
    quote do
      alias Dolphin.Worker


      opts = unquote(opts)
      @manager_module opts |> Keyword.get(:manager_module)
      if !@manager_module do
        raise "Dolphin.Worker requires a :manager_module"
      end

      @queue_module opts |> Keyword.get(:queue_module)
      if !@queue_module do
        raise "Dolphin.Worker requires a :queue_module"
      end

      @handler_module opts |> Keyword.get(:handler_module, __MODULE__)
      if @handler_module == __MODULE__ do
        @behaviour Dolphin.Handler
      end

      def start_link(name) do
        GenServer.start_link(__MODULE__, name, name: name)
      end

      def init(name) do
        @manager_module.remove_worker(name)
        @manager_module.add_worker(name)
        send self(), :start_worker
        {:ok, %Worker{
          name: name,
        }}
      end

      def terminate(a, b) do
        @handler_module.handle_terminate({a, b})
      end

      def state(name),  do: GenServer.call(name, :state)

      def start_worker(%{name: name}), do: start_worker(name)
      def start_worker(name) do
        case Process.whereis(name) do
          nil -> raise "Invalid name - No Process for #{inspect name}"
          pid -> send pid, :start_worker
        end
      end

      # state, halt and resume
      def handle_call(:state, _from, state) do
        {:reply, state, state}
      end

      def handle_info(:start_worker, state) do
        work_loop
        {:noreply, state}
      end

      def work_loop do
        if running? do
          pop_then_handle_work
          work_loop
        end
      end

      def running? do
        @manager_module.running?
      end

      def pop_then_handle_work do
        with :ok <- :ok,
          {:ok, job}    <- get_job,
          {:ok, result} <- @handler_module.handle_work(job),
          :ok           <- @handler_module.handle_success(result)
        do
          :ok
        else
          {:error, :empty_queue} ->
            @manager_module.stop_workers
            :stopping
          {:error, _} = err ->
            @handler_module.handle_failure(err)
        end
      end

      def get_job do
        case @queue_module.pop do
          {:ok, [job]} ->
            {:ok, job}
          {:error, _} = err ->
            err
        end
      end

    end
  end
end
