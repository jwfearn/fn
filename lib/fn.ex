defmodule Fn do
  def identity, do: &(&1)
  def const(v), do: fn -> v end
  def _0, do: const(0)
  def _1, do: const(1)
  def _nil, do: const(nil)
  def _true, do: const(true)
  def _false, do: const(false)
  def _raise(ex), do: fn -> raise ex end
  def eq(v), do: &(&1 == v)

#  def match(v), do: &(&1 === v)
#  def not(f), do: fn -> !f.() end

  def compose(fs) when is_list(fs), do: fs |> Enum.reverse |> rcompose

  def rcompose([f]) when is_function(f), do: f
  def rcompose([f | tail]) when is_function(f), do: &(rcompose(tail).(f.(&1)))

  def arity(f), do: f |> :erlang.fun_info |> Keyword.get(:arity)

  @type fn_more_arity_t :: ((...) -> any)
  @type fn_less_arity_t :: ((...) -> any)

  @doc ~S"""
  xxx

  ## Example

    iex> f3 = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
    iex> f2 = Fn.bind(f3, [3, 4])
    iex> f2.(1, 2)
    "a=1, b=2, c=3, d=4"
  """

  @spec bind(fn_more_arity_t, list(any)) :: fn_less_arity_t
  def bind(f, []) when is_function(f), do: f
  def bind(f, args) when is_list(args) do
    case arity(f) - Enum.count(args) do
    0 -> fn -> apply(f, args) end
    1 -> fn a -> apply(f, [a] ++ args) end
    2 -> fn a, b -> apply(f, [a, b] ++ args) end
    3 -> fn a, b, c -> apply(f, [a, b, c] ++ args) end
    4 -> fn a, b, c, d -> apply(f, [a, b, c, d] ++ args) end
    5 -> fn a, b, c, d, e -> apply(f, [a, b, c, d, e] ++ args) end
    6 -> fn a, b, c, d, e, f -> apply(f, [a, b, c, d, e, f] ++ args) end
    7 -> fn a, b, c, d, e, f, g -> apply(f, [a, b, c, d, e, f, g] ++ args) end
    end
  end
end
