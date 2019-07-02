defmodule Logflare.BigQuery.EctoQueryBQ do
  @moduledoc false
  alias Logflare.Sources
  alias Logflare.EctoQueryBQ
  use Logflare.DataCase
  import Ecto.Query
  import Logflare.DummyFactory

  setup do
    u = insert(:user, email: System.get_env("LOGFLARE_TEST_USER_WITH_SET_IAM"))
    s = insert(:source, user_id: u.id)
    s = Sources.get_by(id: s.id)
    {:ok, sources: [s], users: [u]}
  end

  describe "where_nested_eq" do
    test "1 level deep", %{sources: [source | _], users: [user | _]} do
      bq_table_id = System.get_env("LOGFLARE_DEV_BQ_TABLE_ID_FOR_TESTING")

      path = "metadata.datacenter"
      value = "ne-1"

      q =
        from(bq_table_id)
        |> select([:timestamp, :metadata])
        |> EctoQueryBQ.where_nested_eq(path, value)

      {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, q)

      sql = EctoQueryBQ.ecto_pg_sql_to_bq_sql(sql)

      assert sql ==
               ~s|SELECT t0.timestamp, t0.metadata FROM #{bq_table_id} AS t0 INNER JOIN UNNEST(t0.metadata) AS f1 ON TRUE WHERE (f1.datacenter = ?)|

      assert params == ["ne-1"]
    end
  end
end
