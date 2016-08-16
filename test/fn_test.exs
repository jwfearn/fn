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

  test "const" do
    assert Fn.const(0).() == 0
    assert Fn.const(1).() == 1
    assert Fn.const(nil).() == nil
    assert Fn.const(true).() == true
    assert Fn.const(false).() == false
  end

  test "_0", do: assert Fn._0.() == 0
  test "_1", do: assert Fn._1.() == 1
  test "_nil", do: assert Fn._nil.() == nil
  test "_true", do: assert Fn._true.() == true
  test "_false", do: assert Fn._false.() == false

  test "eq" do
    assert Fn.eq(0).(0) == true
    assert Fn.eq(1).(1) == true
    assert Fn.eq(nil).(nil) == true
    assert Fn.eq(true).(true) == true
    assert Fn.eq(false).(false) == true
  end

  test "arity" do
    assert Fn.arity(fn -> nil end) == 0
    assert Fn.arity(fn _ -> nil end) == 1
    assert Fn.arity(fn _, _ -> nil end) == 2
    assert Fn.arity(fn _, _, _ -> nil end) == 3
  end

  describe "compose" do
    test "empty list raises", do: catch_error(Fn.compose [])
    test "non functions raise", do: catch_error(Fn.compose [0])
    test "single function" do
      f = fn v -> v * 10 end
      assert Fn.compose([f]).(0) == f.(0)
    end
    test "multiple functions" do
      f = fn v -> v * 10 end
      g = fn v -> v + 3 end
      h = fn v -> v * v end
      fgh = fn v -> f.(g.(h.(v))) end
      assert (Fn.compose [f, g, h]).(0) == fgh.(0)
    end
  end

  describe "rcompose" do
    test "empty list raises", do: catch_error(Fn.rcompose [])
    test "non functions raise", do: catch_error(Fn.rcompose [0])
    test "single function" do
      f = fn v -> v * 10 end
      assert Fn.rcompose([f]).(0) == f.(0)
    end

    test "temperature conversions" do
      # °F to °C => Deduct 32, then multiply by 5, then divide by 9
      f2c = Fn.rcompose [&(&1 - 32), &(&1 * 5), &(&1 / 9)]

      # °C to °F => Multiply by 9, then divide by 5, then add 32
      c2f = Fn.rcompose [&(&1 * 9), &(&1 / 5), &(&1 + 32)]

      assert f2c.(32) == 0.0
      assert c2f.(0) == 32.0
      assert f2c.(212) == 100.0
      assert c2f.(100) == 212.0
    end
  end

  describe "bind" do
    test "no arguments" do
      f = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
      f3 = Fn.bind(f, [])
      assert f3.(1, 2, 3, 4) == "a=1, b=2, c=3, d=4"
    end

    test "single argument" do
      f = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
      f2 = Fn.bind(f, [4])
      assert f2.(1, 2, 3) == "a=1, b=2, c=3, d=4"
    end

    test "multiple arguments" do
      f = fn a, b, c, d -> "a=#{a}, b=#{b}, c=#{c}, d=#{d}" end
      f2 = Fn.bind(f, [3, 4])
      assert f2.(1, 2) == "a=1, b=2, c=3, d=4"
      f0 = Fn.bind(f2, [1, 2])
      assert f0.() == "a=1, b=2, c=3, d=4"
    end

    test "too many arguments raises" do
      catch_error(Fn.bind(&(&1), [0, 1]).())
    end
  end
end
