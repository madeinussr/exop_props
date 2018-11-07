defmodule ExopProps.ParamsGenerator do
  @moduledoc """
  Defines functions for generationg StreamData generator.
  """

  use ExUnitProperties

  alias ExopProps.ParamsGenerator.CommonFilters

  @doc """
  Returns a StreamData generator for either an Exop operation or a contract.
  """
  @spec generate_for(module() | ExopProps.contract(), keyword()) :: StreamData.t()
  def generate_for(contract, opts) when is_list(contract) do
    contract
    |> Enum.into(%{}, &generator_for_param(&1, opts))
    |> StreamData.fixed_map()
  end

  def generate_for(operation, opts) when is_atom(operation) do
    {:module, operation} = Code.ensure_compiled(operation)
    generate_for(operation.contract(), opts)
  end

  def generate_for(_) do
    raise("""
    ExopProps: please provide either an operation's contract
    or operation's module to make a generator
    """)
  end

  defp generator_for_param(%{name: param_name, opts: param_opts}, opts) do
    generators = Keyword.get(opts, :generators, %{})
    param_generator = Map.get(generators, param_name)

    if param_generator do
      {param_name, param_generator}
    else
      {param_name, build_generator(param_opts, opts)}
    end
  end

  defp build_generator(param_opts, _opts) do
    param_opts = Enum.into(param_opts, [])
    exact_opt = Keyword.get(param_opts, :exact)
    in_list_opt = Keyword.get(param_opts, :in)

    resolve_exact(exact_opt) || resolve_in_list(in_list_opt) || resolve_opts(param_opts)
  end

  @doc """
  Returns a StreamData generator for parameter's opts.
  """
  @spec resolve_opts(keyword()) :: StreamData.t()
  def resolve_opts(param_opts) do
    param_type = Keyword.get(param_opts, :type) || :term

    param_opts =
      if param_type == :struct && Keyword.get(param_opts, :struct) do
        %struct_module{} = Keyword.get(param_opts, :struct)
        Keyword.put(param_opts, :struct_module, struct_module)
      else
        Keyword.put(param_opts, :type, :map)
      end

    generator_module =
      [
        ExopProps.ParamsGenerator,
        param_type |> Atom.to_string() |> String.capitalize()
      ]
      |> Module.concat()

    if Code.ensure_compiled?(generator_module) do
      generator_module |> apply(:generate, [param_opts]) |> CommonFilters.filter(param_opts)
    else
      raise("""
      ExopProps: there is no generator for params of type :#{param_type},
      you can add your own clause for such params
      """)
    end
  end

  @spec resolve_exact(any()) :: StreamData.t() | nil
  def resolve_exact(nil), do: nil

  def resolve_exact(value), do: StreamData.constant(value)

  @spec resolve_in_list([any()]) :: StreamData.t() | nil
  def resolve_in_list(in_list) when is_list(in_list), do: StreamData.member_of(in_list)

  def resolve_in_list(_), do: nil
end
