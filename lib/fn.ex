defmodule Fn do
  @type t :: (() -> any)
  @type arity_0_fn_t :: t
  @type arity_1_fn_t :: ((any) -> any)
  @type arity_n_fn_t :: ((...) -> any)

  @spec identity :: ((any) -> any)
  def identity, do: &(&1)

  @spec constant(any) :: t
  def constant(v), do: fn -> v end

  def _0, do: constant(0)
  def _1, do: constant(1)
  def _nil, do: constant(nil)
  def _true, do: constant(true)
  def _false, do: constant(false)
  def ok, do: constant(:ok)
  def ok(v), do: constant({:ok, v})
  def error, do: constant(:error)
  def error(v), do: constant({:error, v})
  def _raise(v), do: fn -> raise(v) end
  def _raise(v, message), do: fn -> raise(v, message) end
  def eq(v), do: &(&1 == v)
  def match(v), do: &(&1 === v)

  @spec _not(t) :: t
  def _not(f), do: fn -> !f.() end

  @spec _and(list(t)) :: t # logical 'and'' with short-circuit
  def _and([f]) when is_function(f), do: f
  def _and([f | t]), do: fn -> f.() && _and(t).() end

  @spec _or(list(t)) :: t # logical 'or' with short-circuit
  def _or([f]) when is_function(f), do: f
  def _or([f | t]), do: fn -> f.() || _or(t).() end

  @spec compose(list(arity_1_fn_t)) :: arity_1_fn_t
  def compose(v) when is_list(v), do: v |> Enum.reverse |> rcompose

  @spec rcompose(list(arity_1_fn_t)) :: arity_1_fn_t
  def rcompose([f]) when is_function(f), do: f
  def rcompose([f | tail]) when is_function(f), do: &(rcompose(tail).(f.(&1)))

  @spec arity(arity_n_fn_t) :: integer
  def arity(f), do: :erlang.fun_info(f)[:arity]

  # Takes a zero-arity function that may raise exceptions and returns a new
  # zero-arity function that does not raise exceptions, converting exceptions
  # to an error tuple.
  def ex_to_err(f, error_tag \\ :error) do
    fn ->
      try do
        f.()
      rescue ex -> {error_tag, ex}
      end
    end
  end

  # Takes a zero-arity function that may return an error atom or tuple and
  # returns a new zero-arity function that raises exceptions, converting
  # errors to an exception.
  def err_to_ex(f, exception_module \\ RuntimeError, error_tag \\ :error) do
    fn ->
      ret = f.()
      raise_fn = Fn._raise(exception_module, ret |> inspect)
      case ret do
        {^error_tag, _} -> raise_fn.()
        ^error_tag -> raise_fn.()
        _ -> ret
      end
    end
  end

#  @type fn_more_arity_t :: ((...) -> any)
#  @type fn_less_arity_t :: ((...) -> any)

#  doc ~S"""
#  xxx
#
#  ## Example
#
#    xiex> f3 = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
#    xiex> f2 = Fn.partial(f3, [3, 4])
#    xiex> f2.(1, 2)
#    x"a=1, b=2, c=3, d=4"
#  """

#  @spec partial(fn_more_arity_t, list(any)) :: fn_less_arity_t
#  def partial(f, []) when is_function(f), do: f
#  def partial(f, args) when is_list(args) do
#    case arity(f) - Enum.count(args) do
#    0 -> fn -> apply(f, args) end
#    1 -> fn a -> apply(f, [a] ++ args) end
#    2 -> fn a, b -> apply(f, [a, b] ++ args) end
#    3 -> fn a, b, c -> apply(f, [a, b, c] ++ args) end
#    4 -> fn a, b, c, d -> apply(f, [a, b, c, d] ++ args) end
#    5 -> fn a, b, c, d, e -> apply(f, [a, b, c, d, e] ++ args) end
#    6 -> fn a, b, c, d, e, f -> apply(f, [a, b, c, d, e, f] ++ args) end
#    7 -> fn a, b, c, d, e, f, g -> apply(f, [a, b, c, d, e, f, g] ++ args) end
#    end
#  end

#  defmacro partial({fun, context, args}) do
#  defmacro partial({atom, context, args}) do
#    cnt_args = Enum.count(args)
#    arity_in = arity(f)
#    arity_out = arity_in - cnt_args
#    IO.puts "partial: fun=#{inspect unquote(fun)}, context=#{inspect unquote(context)}, args=#{inspect unquote(args)}"
#    quote(fn -> unquote(arg) end)

#@doc ~S"""
#
#  quote do partial(f, 1, 2, 3) end
#  {:partial, [], [{:f, [], Elixir}, 1, 2, 3]}
#  {
#    :partial,   # atom
#    [],         # context
#    [           # args
#      {
#        :f,     # atom
#        [],     # context
#        Elixir  # args
#      },
#      1,
#      2,
#      3
#    ]
#  }
#
#  f1 = &(&1)
#  quote do partial(f1, 42) end
#  {:partial, [], [{:f1, [], Elixir}, 42]}
#
#  quote do partial(&(&1), 42) end
#  {
#    :partial,            # atom
#    [],                  # context for :partial
#    [                    # args for :partial
#      {                  # arg 1 (a function value)
#        :&,
#        [],
#        [
#          {:&, [], [1]}
#        ]
#      },
#      42                 # arg 2 (an integer in this case)
#    ]
#  }
#"""
#
#  defmacro partial({f, _, args} = ast) when is_function(f) and is_list(args) do
#    IO.puts "partial: f=#{inspect f}, args=#{inspect args}"
#    quote do
#     fn -> 42 end
#   end
#  end

  # partial/2: partial(function, args) # similar to apply/2
  # partial/3: partial(module_name, function_name, args) # similar to apply/3

#  def partial(f, args) do
#    a = f |> arity
#    n = args |> Enum.count
#    # assert n <= a
#    &(apply(f, make_args(n, args))
#  end
#
#  defp make_args(n, args) do
#    1..n |> Enum.map(fn i -> "&#{i}" end) |> Enum.join(",")
#  end


"""
iex> a = fn f -> :erlang.fun_info(f)[:arity] end
#Function<6.52032458/1 in :erl_eval.expr/5>
iex> f6 = fn a, b, c, d, e, f -> a + b + c + d + e + f end # arity 6
#Function<17.52032458/6 in :erl_eval.expr/5>
iex> a.(f6)
6
iex> f6.(1, 2, 3, 4, 5, 6)
21
iex> g3 = &(apply(f6, [&1, &2, &3, 4, 5, 6]))
#Function<18.52032458/3 in :erl_eval.expr/5>
iex> a.(g3)
3
iex> g3.(1, 2, 3)
21
iex> h3 = partial(f6, [4, 5, 6]) # equivalent to: h3 = &(apply(f6, [&1, &2, &3, 4, 5, 6]))


iex> f0 = fn -> 0 end # arity 0
#Function<20.52032458/0 in :erl_eval.expr/5>
iex> h0 = partial(f0, []) # equivalent to: h0 = f0
iex> ha = partial(fa, []) # equivalent to: ha = fa # for any arity a
"""
end
