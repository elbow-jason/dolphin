defmodule Dolphin.GenServerQueue do

  defmacro __using__(_) do
    quote do
      use GenServer

      # API
      def append(items) when is_list(items) do
        GenServer.call(__MODULE__, {:append, items})
      end
      def append(item) do
        item
        |> List.wrap
        |> append
      end

      def swap(new_items) when is_list(new_items) do
        GenServer.call(__MODULE__, {:swap, new_items})
      end
      def swap(item) do
        item
        |> List.wrap
        |> swap
      end

      def push(items) when items |> is_list do
        GenServer.call(__MODULE__, {:push, items})
      end
      def push(item) do
        item
        |> List.wrap
        |> push
      end

      def prepend(items) when items |> is_list do
        GenServer.call(__MODULE__, {:prepend, items})
      end
      def prepend(item) do
        item
        |> List.wrap
        |> prepend
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

      def handle_call({:append, items}, _from, state) do
        {:reply, :ok, state ++ items}
      end
      def handle_call({:prepend, items}, _from, state) do
        {:reply, :ok, items ++ state}
      end
      def handle_call({:push, items}, _from, state) do
        {:reply, :ok, state ++ items}
      end
      def handle_call({:pop, _}, _from, []) do
        {:reply, {:error, :empty_queue}, []}
      end
      def handle_call({:pop, count}, _from, state) do
        {popped, rest} = Enum.split(state, count)
        {:reply, {:ok, popped}, rest}
      end
      def handle_call(:list, _from, state) do
        {:reply, state, state}
      end
      def handle_call(:clear, _from, _) do
        {:reply, :ok, []}
      end
      def handle_call({:swap, new_state}, _from, state) do
        {:reply, state, new_state}
      end

    end
  end

end
