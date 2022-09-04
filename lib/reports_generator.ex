defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @options ["orders", "users"]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(build_report(), &generate_report(&1, &2))
  end

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please, provide a list of strings."}
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(build_report(), fn {:ok, result}, report ->
        merge_reports(report, result)
      end)

    {:ok, result}
  end

  def fetch_higher_cost(report, option) when option in @options do
    {:ok, Enum.max_by(report[option], fn {_key, value} -> value end)}
  end

  def fetch_higher_cost(_report, _option) do
    {:error, "Invalid Option! Possible options: #{Enum.join(@options, " ")}"}
  end

  defp merge_reports(report, result) do
    users = sum_maps(report["users"], result["users"])
    orders = sum_maps(report["orders"], result["orders"])

    build_report(users, orders)
  end

  defp sum_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, map1_value, map2_value -> map1_value + map2_value end)
  end

  defp generate_total(map_report, key, value) do
    case map_report[key] do
      nil -> value
      _ -> map_report[key] + value
    end
  end

  defp generate_report([id, order, price], %{"users" => users, "orders" => orders}) do
    users = Map.put(users, id, generate_total(users, id, price))
    orders = Map.put(orders, order, generate_total(orders, order, 1))

    build_report(users, orders)
  end

  defp build_report(users \\ %{}, orders \\ %{}), do: %{"users" => users, "orders" => orders}
end
