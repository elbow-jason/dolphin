defmodule Dolphin.Queue do

  defmacro __using__(_) do
    quote do
      use GenServer
      require Logger

      # API
      def push(items) when is_list(items) do
        GenServer.call(__MODULE__, {:push, items})
      end
      def push(item) do
        push([item])
      end

      def list do
        GenServer.call(__MODULE__, :list)
      end

      def pop(count \\ 1) when count |> is_integer do
        GenServer.call(__MODULE__, {:pop, count})
      end

      def clear do
        GenServer.call(__MODULE__, :clear)
      end

      # SERVER
      def start_link do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
      end

      def handle_call({:push, items}, _from, state) do
        new_state = state ++ items
        log_status(new_state, {:push, length(items)})
        {:reply, :ok, new_state}
      end
      def handle_call({:pop, _}, _from, []) do
        log_status([], :empty_queue)
        {:reply, {:error, :empty_queue}, []}
      end
      def handle_call({:pop, count}, _from, state) do
        {popped, rest} = Enum.split(state, count)
        log_status(rest, {:pop, popped})
        {:reply, {:ok, popped}, rest}
      end
      def handle_call(:list, _from, state) do
        {:reply, state, state}
      end
      def handle_call(:clear, _from, _) do
        log_status([], :clear)
        {:reply, :ok, []}
      end

      def log_status(state, action) do
        Logger.debug("""
        
        [MODULE]#{__MODULE__}
        [ACTION] #{inspect action}
        [ENQUEUED] #{length(state)}
        [NEXT] #{state |> List.first |> inspect}
        """)
      end
    end
  end

end
