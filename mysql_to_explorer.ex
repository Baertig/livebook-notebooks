defmodule MySqlToExplorer do
  import Decimal
  def transform(mysql_result) do
  mysql_result.rows
  |> Enum.map(fn row -> 
      Enum.map(row, fn val when is_decimal(val) -> Decimal.to_float(val)
          val -> val
          end)
    end)
  |> Enum.reduce(create_acc(mysql_result.columns), fn row, acc -> 
    Enum.with_index(row, 
      fn value, index -> {Enum.fetch!(mysql_result.columns, index), value} end)
    |> Enum.into(%{})
    |> Map.merge(acc, fn _k, v_new, array -> [v_new| array] end)
  end)
  |> Enum.map(fn {k,v} -> {k, Explorer.Series.from_list(v)} end)
  |> Explorer.DataFrame.new()
end

  defp create_acc(columns) do
    Enum.map(columns, fn col -> {col, []} end ) |>Enum.into(%{}) 
  end
end
