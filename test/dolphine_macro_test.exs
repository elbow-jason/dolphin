defmodule DolphinMacroTest do
  use Dolphin

  def handle_work({:function, func}) do
    payload = func.()
    IO.puts("#{inspect payload}")
    {:ok, payload}
  end
  def handle_work({:url, url}) do
    :timer.sleep(150)
    {:ok, url}
  end

  def handle_work(x) do
    raise "Bad handle_work - #{inspect x}"
  end

  def handle_success(_x) do
    # IO.puts("SUCCESS!! #{inspect x}")
    :ok
  end

  def handle_failure(x) do
    payload = {:failure, x}
    IO.puts("#{inspect payload}")
    :ok
  end

  def handle_terminate(x) do
    payload = {:terminate, x}
    IO.puts("#{inspect payload}")
    payload
  end


end
