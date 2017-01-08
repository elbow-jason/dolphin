defmodule Dolphin.Worker do
  defmacro __using__(opts) do
    quote do

      use Slogger, level: :info

      opts = unquote(opts)
      @manager_module opts |> Keyword.get(:manager_module)
      if !@manager_module do
        raise "Dolphin.Worker requires a :manager_module"
      end

      @queue_module opts |> Keyword.get(:queue_module)
      if !@queue_module do
        raise "Dolphin.Worker requires a :queue_module"
      end

      #@timeout_ms opts |> Keyword.get(:timeout, 60_000)


      def start_link(name) do
        GenServer.start_link(__MODULE__, name, name: name)
      end

      def init(name) do
        @manager_module.remove_worker(name)
        @manager_module.add_worker(name)
        async_process_job(name)
        {:ok, name}
      end

      def handle_cast(:start_worker, name) do
        async_process_job(name)
        {:noreply, name}
      end

      def start_worker(name) do
        GenServer.cast(name, :start_worker)
      end

      defp async_process_job(name) do
        if @manager_module.running? do
          :timer.apply_after(0, __MODULE__, :process_job, [name])
        end
      end

      def process_job(name) do
        case @queue_module.pop do
          {:ok, [job]} ->
            Slogger.debug("#{__MODULE__} - worker: #{inspect name} - Processing - #{inspect job}")
            GenServer.call(name, job)
            :ok
          {:error, reason} ->
            Slogger.debug("#{__MODULE__} - worker: #{inspect name} - Stopping - #{inspect reason}")
            @manager_module.stop_workers
        end
      end

    end
  end
end
