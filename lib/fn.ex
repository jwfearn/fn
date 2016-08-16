defmodule Fn do
  def identity, do: fn(v) -> v end
  def const(v), do: fn -> v end
  def _0, do: const(0)
  def _1, do: const(1)
  def _nil, do: const(nil)
  def _true, do: const(true)
  def _false, do: const(false)
  def _raise(ex), do: fn -> raise ex end
  def eq(v), do: &(&1 == v)

  def arity(f), do: :erlang.fun_info(f) |> Keyword.get(:arity)

  def compose(fs) when is_list(fs), do: fs |> Enum.reverse |> rcompose


  def rcompose([f]) when is_function(f), do: f
  def rcompose([f | tail]) when is_function(f) do
    fn v -> rcompose(tail).(f.(v)) end
  end
#  def compose([f | tail], do: tail |> compose |> const
#  def match(v), do: &(&1 === v)
#  def not(f), do: fn -> !f.() end
#  def bind(f0, args) do
#    n0 = arity(f)
#    f1 = fn -> apply(f, args) end
#    f1
#  end
#
  def _apply(f, args), do: fn -> apply(f, args) end


  @doc ~S"""
  Parameters:
  f - a function of arity N
  args - a list of length L <= N
  Returns - a new function of arity N - L, with the values from args bound to
  t

  ## Examples

    xiex> f3 = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
    xiex> f2 = Fn.bind(f3, [3, 4])
    xiex> f2.(1, 2)
    x"a=1, b=2, c=3, d=4"
  """

#  @spec bind((...) -> any, list(any)) :: any
  def bind(f, []) when is_function(f), do: f
#  def bind([f | tail]) when is_function(f) do
#  end
end

# defmodule Fn do
#   def compose([f | fs]), do: fn -> f.(compose(fs)) end
# end

# TODO: err

# def bind(f, [h | t])

# def compose([f]), do: fn -> f.() end
# def compose([f | t]), do: fn -> f.(compose(t).()) end

# def _0, do: const(0)
# def _1, do: const(1)
# def empty_string, do: const("")
# def empty_list, do: const([])
# def empty_tuple, do: const({})
# def empty_map, do: const(%{})
