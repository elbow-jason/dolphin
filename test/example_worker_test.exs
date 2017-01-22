defmodule DolphinTest.Worker do
  use Dolphin.Worker, [
    manager_module: DolphinTest.Manager,
    queue_module: DolphinTest.Queue,
  ]

  def handle_work({:add, pid, a, b}) do
    send pid, {:added, a + b}
    {:ok, a + b}
  end

  def handle_work({:exec, func}) do
    IO.puts("handle_work - start #{inspect func}")
    result = func.()
    IO.puts("handle_work - result #{inspect result}")
    {:ok, result}
  end

  def handle_success(result) do
    IO.puts("handle_success - result #{inspect result}")
  end

  def handle_failure({:error, _} = err) do
    IO.puts("handle_failure - err #{inspect err}")
  end

  def handle_terminate(arg) do
    IO.puts("handle_terminate - arg #{inspect arg}")
  end

end
