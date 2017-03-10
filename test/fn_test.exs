defmodule FnTest do
  use ExUnit.Case
  doctest Fn

  test "identity" do
    assert Fn.identity.(0) == 0
    assert Fn.identity.(1) == 1
    assert Fn.identity.(nil) == nil
    assert Fn.identity.(true) == true
    assert Fn.identity.(false) == false
  end

  test "constant" do
    assert Fn.constant(0).() == 0
    assert Fn.constant(1).() == 1
    assert Fn.constant(nil).() == nil
    assert Fn.constant(true).() == true
    assert Fn.constant(false).() == false
  end

  test "_0", do: assert Fn._0.() == 0
  test "_1", do: assert Fn._1.() == 1
  test "_nil", do: assert Fn._nil.() == nil
  test "_true", do: assert Fn._true.() == true
  test "_false", do: assert Fn._false.() == false
  test "ok/0", do: assert Fn.ok.() == :ok
  test "ok/1", do: assert Fn.ok(0).() == {:ok, 0}
  test "error/0", do: assert Fn.error.() == :error
  test "error/1", do: assert Fn.error(1).() == {:error, 1}

  test "raise", do: assert_raise(RuntimeError, Fn._raise("fail"))

  test "eq" do
    assert Fn.eq(0).(0)
    assert Fn.eq(1).(1)
    assert Fn.eq(nil).(nil)
    assert Fn.eq(true).(true)
    assert Fn.eq(false).(false)
  end

  test "arity" do
    assert 0 == Fn.arity(fn -> nil end)
    assert 1 == Fn.arity(fn _ -> nil end)
    assert 2 == Fn.arity(fn _, _ -> nil end)
    assert 3 == Fn.arity(fn _, _, _ -> nil end)
  end

  describe "compose" do
    test "empty list raises", do: catch_error(Fn.compose([]))
    test "non functions raise", do: catch_error(Fn.compose([0]))

    test "single function" do
      assert 3 == Fn.compose([&(&1 + 2)]).(1)
    end

    test "multiple functions" do
      plus2 = &(&1 + 2)
      times2 = &(&1 * 2)

      assert 3 == Fn.compose([plus2]).(1)
      assert 6 == Fn.compose([times2, plus2]).(1)
      assert 4 == Fn.compose([plus2, times2]).(1)
      assert 6 == Fn.compose([plus2, plus2, times2]).(1)
      assert 12 == Fn.compose([times2, plus2, plus2, times2]).(1)
    end
  end

  describe "rcompose" do
    test "empty list raises", do: catch_error(Fn.rcompose([]))
    test "non functions raise", do: catch_error(Fn.rcompose([0]))
    test "single function" do
      f = fn v -> v * 10 end
      assert f.(0) == Fn.rcompose([f]).(0)
    end

    test "multiple functions (temperature conversion)" do
      # °C to °F => Multiply by 9, then divide by 5, then add 32
      c2f = Fn.rcompose([&(&1 * 9), &(&1 / 5), &(&1 + 32)])

      # °F to °C => Deduct 32, then multiply by 5, then divide by 9
      f2c = Fn.rcompose([&(&1 - 32), &(&1 * 5), &(&1 / 9)])

      assert c2f.(0) == 32.0
      assert f2c.(32) == 0.0
      assert c2f.(100) == 212.0
      assert f2c.(212) == 100.0
    end
  end

  test "_not/1" do
    refute Fn._not(fn -> true end).()
    assert Fn._not(fn -> false end).()
  end

  test "_and/1 short circuits" do
    f = Fn._and([
      fn -> true end, # keep going
      fn -> false end, # return
      fn -> raise "should never get here" end
    ])
    refute f.()
  end

  test "_or/1 short circuits" do
    f = Fn._or([
      fn -> false end, # keep going
      fn -> true end, # return
      fn -> raise "should never get here" end
    ])
    assert f.()
  end

  describe "partial" do
#    due = fn(tax, units, price, ship) -> (units * price * (1 + tax)) + ship end

#    free_ship1 = &(due(&1, &2, &3, 0))
#    free_ship2 = Fn.rpartial(due, 0)
#
#    no_tax1 = &(due(0, &1, &2, &3))
#    no_tax2 = Fn.partial(due, 0)

#    test "no arguments" do
#      f = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
#      f3 = Fn.partial(f, [])
#      assert f3.(1, 2, 3, 4) == "a=1, b=2, c=3, d=4"
#    end
#
#    test "single argument" do
#      f = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
#      f2 = Fn.partial(f, [4])
#      assert f2.(1, 2, 3) == "a=1, b=2, c=3, d=4"
#    end
#
#    test "multiple arguments" do
#      f = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
#      f2 = Fn.partial(f, [3, 4])
#      assert f2.(1, 2) == "a=1, b=2, c=3, d=4"
#      f0 = Fn.partial(f2, [1, 2])
#      assert f0.() == "a=1, b=2, c=3, d=4"
#    end
#
#    test "too many arguments raises" do
#      catch_error(Fn.partial(&(&1), [0, 1]).())
#    end
#    test "no args" do
#      f0 = fn -> 42 end
#      g0 = Fn.partial(f0, [])
#      assert f0.() == g0.()
#    end

#    test "one arg" do
#      f1 = &(&1)
#      f0 = Fn.partial(f1, 42)
#      assert f0.() == 42
#    end
  end

  defmodule MyError, do: defexception message: __MODULE__

  describe "ex_to_err" do
    test "with default tag" do
      f = Fn.ex_to_err(fn -> raise "s" end)
      assert {:error, %RuntimeError{message: "s"}} = f.()
    end

    test "with custom tag" do
      f = Fn.ex_to_err(fn -> raise "s" end, :x)
      assert {:x, %RuntimeError{message: "s"}} = f.()
    end

    test "with custom error" do
      f = Fn.ex_to_err(fn -> raise(MyError, "s") end)
      assert {:error, %MyError{message: "s"}} = f.()
    end

    test "with custom error and custom tag" do
      f = Fn.ex_to_err(fn -> raise(MyError, "s") end, :x)
      assert {:x, %MyError{message: "s"}} = f.()
    end

    test "without exceptions" do
      assert Fn.ex_to_err(fn -> true end).()
    end
  end

  describe "err_to_ex" do
    test "raises RuntimeError by default" do
      assert_raise(RuntimeError, Fn.err_to_ex(fn -> :error end))
      assert_raise(RuntimeError, Fn.err_to_ex(fn -> {:error, "s"} end))
    end

    test "can raise a custom error" do
      assert_raise(MyError, Fn.err_to_ex(fn -> :error end, MyError))
      assert_raise(MyError, Fn.err_to_ex(fn -> {:error, "s"} end, MyError))
      assert_raise(MyError, Fn.err_to_ex(fn -> :x end, MyError, :x))
      assert_raise(MyError, Fn.err_to_ex(fn -> {:x, "s"} end, MyError, :x))
    end

    test "without errors" do
      assert Fn.err_to_ex(fn -> true end).()
    end
  end
end
