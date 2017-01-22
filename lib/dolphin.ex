defmodule Dolphin do

  defmacro __using__(opts) do
    quote do
      opts = unquote(opts)

      worker_module  = Keyword.get(opts,  :worker_module)
      queue_module   = Keyword.get(opts,  :queue_module)
      manager_module = Keyword.get(opts,  :manager_module)
      handler_module = Keyword.get(opts,  :handler_module, __MODULE__)
      Module.put_attribute(__MODULE__, :handler_module, handler_module)
      if handler_module == __MODULE__ do
        @behaviour Dolphin.Handler
      end


      if is_nil(manager_module) do
        manager_name  = Module.concat(__MODULE__, "Manager")
        worker_name   = worker_module  || Module.concat(__MODULE__, "Worker")
        defmodule manager_name do
          use Dolphin.Manager, [
            worker_module: worker_name
          ]
        end
        Module.put_attribute(__MODULE__, :manager_module, manager_name)
      else
        Module.put_attribute(__MODULE__, :manager_module, manager_module)
      end

      if is_nil(queue_module) do
        queue_name = Module.concat(__MODULE__, "Queue")
        defmodule queue_name do
          use Dolphin.GenServerQueue
        end
        Module.put_attribute(__MODULE__, :queue_module, queue_name)
      else
        Module.put_attribute(__MODULE__, :queue_module, queue_module)
      end

      if is_nil(worker_module) do
        worker_name   = worker_module   || Module.concat(__MODULE__, "Worker")
        manager_name  = manager_module  || Module.concat(__MODULE__, "Manager")
        queue_name    = queue_module    || Module.concat(__MODULE__, "Queue")
        handler_name  = handler_module
        defmodule worker_name  do
          use Dolphin.Worker, [
            manager_module: manager_name,
            queue_module:  queue_name,
            handler_module: handler_name,
          ]
        end
        Module.put_attribute(__MODULE__, :worker_module, worker_name)
      else
        Module.put_attribute(__MODULE__, :worker_module, worker_module)
      end

      def worker_module,  do: @worker_module
      def manager_module, do: @manager_module
      def queue_module,   do: @queue_module
      def handler_module, do: @handler_module

      # defmacro __before_compile__(env) do
      #   quote do
      #
      #   end
      # end


    end
  end
end
