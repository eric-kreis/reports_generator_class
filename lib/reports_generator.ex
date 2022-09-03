defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @options ["orders", "users"]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(%{"users" => %{}, "orders" => %{}}, &generate_report(&1, &2))
  end

  def fetch_higher_cost(report, option) when option in @options do
    {:ok, Enum.max_by(report[option], fn {_key, value} -> value end)}
  end

  def fetch_higher_cost(_report, _option) do
    {:error, "Invalid Option! Possible options: #{Enum.join(@options, " ")}"}
  end

  defp generate_total(map_report, key, value) do
    case map_report[key] do
      nil -> value
      _ -> map_report[key] + value
    end
  end

  defp generate_report([id, order, price], %{"users" => users, "orders" => orders} = report) do
    users = Map.put(users, id, generate_total(users, id, price))
    orders = Map.put(orders, order, generate_total(orders, order, 1))

    %{report | "users" => users, "orders" => orders}
  end
end
