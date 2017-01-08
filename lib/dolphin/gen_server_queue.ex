defmodule Dolphin.GenServerQueue do

  defmacro __using__(_) do
    quote do
      use GenServer
      use Slogger, level: :info

      # API
      def append(items) when is_list(items) do
        GenServer.call(__MODULE__, {:append, items})
      end

      def swap(new_items) when is_list(new_items) do
        GenServer.call(__MODULE__, {:swap, new_items})
      end

      def push(items) when items |> is_list do
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
      def handle_call({:swap, new_state}, _from, state) do
        {:reply, state, new_state}
      end

      def log_status(state, action) do
        Slogger.debug("#{__MODULE__} action: #{inspect action} - enqueued: #{length(state)} - next: #{state |> List.first |> inspect}")
      end

    end
  end

end
