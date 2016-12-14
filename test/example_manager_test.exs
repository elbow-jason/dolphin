defmodule DolphinTest.Manager do
  use Dolphin.Manager, [
    worker_module: DolphinTest.Worker
  ]
end
