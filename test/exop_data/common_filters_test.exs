defmodule ExopData.CommonFiltersTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  describe "allow_nil" do
    property "with 'true' generates at least one nil" do
      contract = [%{name: :a, opts: [type: :integer, allow_nil: true]}]

      check_list = contract |> ExopData.generate() |> Enum.take(1000)

      check_list_ints = Enum.filter(check_list, fn %{a: a} -> is_integer(a) end)
      check_list_nils = Enum.filter(check_list, fn %{a: a} -> is_nil(a) end)

      assert Enum.count(check_list_ints) > 0
      assert Enum.count(check_list_nils) > 0
      assert Enum.count(check_list) == Enum.count(check_list_ints) + Enum.count(check_list_nils)
    end

    property "with 'false' generates without nils" do
      contract = [%{name: :a, opts: [type: :integer, allow_nil: false]}]

      check_list = contract |> ExopData.generate() |> Enum.take(1000)

      check_list_ints = Enum.filter(check_list, fn %{a: a} -> is_integer(a) end)
      check_list_nils = Enum.filter(check_list, fn %{a: a} -> is_nil(a) end)

      assert Enum.count(check_list_nils) == 0
      assert Enum.count(check_list) == Enum.count(check_list_ints)
    end

    property "with 'false' by default" do
      contract = [%{name: :a, opts: [type: :integer]}]

      check_list = contract |> ExopData.generate() |> Enum.take(1000)

      check_list_ints = Enum.filter(check_list, fn %{a: a} -> is_integer(a) end)
      check_list_nils = Enum.filter(check_list, fn %{a: a} -> is_nil(a) end)

      assert Enum.count(check_list_nils) == 0
      assert Enum.count(check_list) == Enum.count(check_list_ints)
    end
  end
end
