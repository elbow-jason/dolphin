defmodule Dolphin.Handler do
  use Behaviour

  defcallback handle_work(any) :: {:ok, any} | {:error, any}
  defcallback handle_success(any) :: :ok     | {:error, any}
  defcallback handle_failure(any) :: :ok
  defcallback handle_terminate(any) :: :ok

end
