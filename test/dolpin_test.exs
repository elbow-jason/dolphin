defmodule DolphinGenServerQueueTest do
  use ExUnit.Case
  doctest Dolphin.GenServerQueue

  setup do
    {:ok, _pid} = DolphinTest.Queue.start_link
    {:ok, _pid} = DolphinTest.Manager.start_link
    {:ok, _pid} = DolphinTest.Worker.start_link(:dolphin_test_worker_01)
    {:ok, _pid} = DolphinTest.Worker.start_link(:dolphin_test_worker_02)
    {:ok, _pid} = DolphinTest.Accumulator.start_link
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
end
