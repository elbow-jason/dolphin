defmodule Dolphin.Logging do

  @log_level Application.get_env(:dolphin, :log_level)
  @levels %{ debug: 0, info: 1, warn: 2, error: 3 }
  @level_names Map.keys(@levels)
  if not @log_level in @level_names do
    raise "Dolphin.Logging requires a config with a :log_level at one of #{inspect @level_names}"
  end


  defmacro debug(item) do
    if @levels[@log_level] <= @levels[:debug] do
      quote do
        IO.puts(IO.ANSI.cyan <> "[debug] #{unquote(item)}")
      end
    else
      quote do
        :ok
      end
    end
  end

  defmacro info(item) do
    if @levels[@log_level] <= @levels[:info] do
      quote do
        IO.puts(IO.ANSI.white <> "[info] #{unquote(item)}")
      end
    else
      quote do
        :ok
      end
    end
  end

  defmacro warn(item) when item |> is_binary do
    if @levels[@log_level] <= @levels[:warn] do
      quote do
        IO.puts(IO.ANSI.yellow <> "[warn] #{unquote(item)}")
      end
    else
      quote do
        :ok
      end
    end
  end


  defmacro error(item) when item |> is_binary do
    if @levels[@log_level] <= @levels[:error] do
      quote do
        IO.puts(IO.ANSI.red <> "[error] #{unquote(item)}")
      end
    else
      quote do
        :ok
      end
    end
  end



end
