defmodule DolphinTest.Accumulator do
  use Dolphin.GenServerQueue
end

defmodule DolphinTest.Worker do
  use Dolphin.Worker, [
    manager_module: DolphinTest.Manager,
    queue_module: DolphinTest.Queue,
  ]

  def handle_call({:add, pid, a, b}, _from, name) do
    send pid, {:added, a + b}
    async_process_job(name)
    {:reply, :ok, name}
  end

end
