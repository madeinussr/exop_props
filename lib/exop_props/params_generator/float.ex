defmodule ExopProps.ParamsGenerator.Float do
  @moduledoc """
  Implements ExopProps generators behaviour for `float` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  @diff 0.1

  def generate(opts \\ %{}), do: opts |> Map.get(:numericality) |> do_generate()

  defp do_generate(%{equal_to: exact}), do: constant(exact)

  defp do_generate(%{equals: exact}), do: constant(exact)

  defp do_generate(%{is: exact}), do: constant(exact)

  defp do_generate(%{greater_than: greater_than, less_than: less_than}) do
    StreamData.filter(
      StreamData.float(min: greater_than - @diff, max: less_than + @diff),
      &(&1 > greater_than && &1 < less_than)
    )
  end

  defp do_generate(%{greater_than: greater_than, less_than_or_equal_to: less_than_or_equal_to}) do
    StreamData.filter(
      StreamData.float(min: greater_than - @diff, max: less_than_or_equal_to),
      &(&1 > greater_than && &1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(%{greater_than_or_equal_to: greater_than_or_equal_to, less_than: less_than}) do
    StreamData.filter(
      StreamData.float(min: greater_than_or_equal_to, max: less_than + @diff),
      &(&1 >= greater_than_or_equal_to && &1 < less_than)
    )
  end

  defp do_generate(%{
         greater_than_or_equal_to: greater_than_or_equal_to,
         less_than_or_equal_to: less_than_or_equal_to
       }) do
    StreamData.filter(
      StreamData.float(min: greater_than_or_equal_to, max: less_than_or_equal_to),
      &(&1 >= greater_than_or_equal_to && &1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(%{greater_than: greater_than}) do
    StreamData.filter(StreamData.float(min: greater_than - @diff), &(&1 > greater_than))
  end

  defp do_generate(%{greater_than_or_equal_to: greater_than_or_equal_to}) do
    StreamData.filter(
      StreamData.float(min: greater_than_or_equal_to),
      &(&1 >= greater_than_or_equal_to)
    )
  end

  defp do_generate(%{less_than: less_than}) do
    StreamData.filter(StreamData.float(max: less_than + @diff), &(&1 < less_than))
  end

  defp do_generate(%{less_than_or_equal_to: less_than_or_equal_to}) do
    StreamData.filter(
      StreamData.float(max: less_than_or_equal_to),
      &(&1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(_), do: StreamData.float()

  defp constant(value), do: StreamData.constant(value)
end
