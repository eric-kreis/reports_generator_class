defmodule ReportsGeneratorTest do
  use ExUnit.Case

  @test_file "report_test.csv"

  describe "build/1" do
    test "builds the report" do
      response = ReportsGenerator.build(@test_file)

      expected_response = %{
        "orders" => %{
          "açaí" => 1,
          "churrasco" => 2,
          "esfirra" => 3,
          "hambúrguer" => 2,
          "pizza" => 2
        },
        "users" => %{
          "1" => 48,
          "2" => 45,
          "3" => 31,
          "4" => 42,
          "5" => 49,
          "6" => 18,
          "7" => 27,
          "8" => 25,
          "9" => 24,
          "10" => 36
        }
      }

      assert response == expected_response
    end
  end

  describe "fetch_higher_cost/2" do
    test "when the option is \"users\", returns the user who spent the most" do
      response =
        @test_file
        |> ReportsGenerator.build()
        |> ReportsGenerator.fetch_higher_cost("users")

      expected_response = {:ok, {"5", 49}}

      assert response == expected_response
    end

    test "when the option is \"orders\", returns the most ordered dish" do
      response =
        @test_file
        |> ReportsGenerator.build()
        |> ReportsGenerator.fetch_higher_cost("orders")

      expected_response = {:ok, {"esfirra", 3}}

      assert response == expected_response
    end

    test "when the given option is invalid, returns an error message" do
      response =
        @test_file
        |> ReportsGenerator.build()
        |> ReportsGenerator.fetch_higher_cost("bananas")

      expected_response = {:error, "Invalid Option! Possible options: orders users"}

      assert response == expected_response
    end
  end
end
