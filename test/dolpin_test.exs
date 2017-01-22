defmodule DolphinGenServerQueueTest do
  use ExUnit.Case
  doctest Dolphin.GenServerQueue

  setup do
    {:ok, _pid} = DolphinTest.Queue.start_link
    {:ok, _pid} = DolphinTest.Manager.start_link
    {:ok, _pid} = DolphinTest.Worker.start_link(:dolphin_test_worker_01)
    {:ok, _pid} = DolphinTest.Worker.start_link(:dolphin_test_worker_02)
    {:ok, _pid} = DolphinMacroTest.Queue.start_link
    {:ok, _pid} = DolphinMacroTest.Manager.start_link
    {:ok, _pid} = DolphinMacroTest.Worker.start_link(:dolphin_macro_test_worker_01)
    #{:ok, _pid} = DolphinTest.Accumulator.start_link
    :ok
  end

  test "things can be added to the queue" do
    DolphinTest.Queue.push([:clap, :clap])
    DolphinTest.Queue.push(:clap)
    assert DolphinTest.Queue.list == [:clap, :clap, :clap]
  end

  test "queue can be cleared" do
    DolphinTest.Queue.push(:clap)
    assert DolphinTest.Queue.list == [:clap]
    DolphinTest.Queue.clear
    assert DolphinTest.Queue.list == []
  end

  test "queue can be popped" do
    DolphinTest.Queue.push([:clap, :clap])
    DolphinTest.Queue.push(:clap)
    assert DolphinTest.Queue.list == [:clap, :clap, :clap]
    assert DolphinTest.Queue.pop == {:ok, [:clap]}
    assert DolphinTest.Queue.list == [:clap, :clap]
  end

  test "queue can be prepended" do
    DolphinTest.Queue.push([:clap, :clap])
    DolphinTest.Queue.prepend([:first, :second])
    assert DolphinTest.Queue.list == [:first, :second, :clap, :clap]
    assert DolphinTest.Queue.pop == {:ok, [:first]}
  end

  test "queue can be multi popped" do
    DolphinTest.Queue.push([:clap, :clap, :clap, :clap])
    DolphinTest.Queue.push(:clap)
    assert DolphinTest.Queue.pop(2) == {:ok, [:clap, :clap]}
    assert DolphinTest.Queue.list == [:clap, :clap, :clap]
  end

  test "results can gathered by an accumulator" do
    DolphinTest.Queue.push({:add, self, 21, 21})
    DolphinTest.Manager.start_workers
    answer_to_life = receive do
      {:added , sum} -> sum
    end
    assert answer_to_life == 42
  end

  test "a worker takes one job at a time even if told to start repeatedly" do
    delay = 100
    func = fn -> :timer.sleep(delay); :ok end
    num_workers = length(DolphinTest.Manager.workers)

    1..num_workers * 2
    |> Enum.map(fn _ -> DolphinTest.Queue.push({:exec, func}) end)


    assert length(DolphinTest.Queue.list) == 2 * num_workers
    DolphinTest.Manager.start_workers
    DolphinTest.Manager.start_workers
    DolphinTest.Manager.start_workers
    DolphinTest.Manager.start_workers
    DolphinTest.Manager.start_workers
    DolphinTest.Manager.start_workers
    assert length(DolphinTest.Queue.list) == num_workers
    :timer.sleep(3 * delay)
    assert DolphinTest.Queue.list == []
  end

  test "use Dolphin macro has the necessary functions" do
    assert DolphinMacroTest.worker_module   == DolphinMacroTest.Worker
    assert DolphinMacroTest.manager_module  == DolphinMacroTest.Manager
    assert DolphinMacroTest.queue_module    == DolphinMacroTest.Queue
    assert DolphinMacroTest.handler_module  == DolphinMacroTest
    funcs = DolphinMacroTest.__info__(:functions)
    assert funcs[:handle_work] == 1 #function arity
    assert funcs[:handle_success] == 1
    assert funcs[:handle_failure] == 1
    assert funcs[:handle_terminate] == 1
  end

  test "use Dolphin macro's modules are functional" do
    this_pid = self()
    func = fn ->
      send this_pid, :payload
    end
    DolphinMacroTest.Queue.push({:function, func})
    assert DolphinMacroTest.Queue.list == [{:function, func}]
    DolphinMacroTest.Manager.start_workers
    receive do
      :payload ->
        :ok
      x ->
        raise "Bad Recieve - #{inspect x}"
    after
      25 ->
        raise "Bad Receive - Timeout"
    end
  end
end
