defmodule EsportsFan.PandascoreApiTest do
  use ExUnit.Case, async: true

  alias Plug.Conn
  alias EsportsFan.PandascoreAPI

  describe "get_all!/2" do
    test "handles pagination correctly" do
      Req.Test.stub(PaginationTest, fn
        %Conn{query_params: %{"page" => "1", "per_page" => "2"}} = conn ->
          send_json_array(conn, ["a", "b"], 1, 2, 5)

        %Conn{query_params: %{"page" => "2", "per_page" => "2"}} = conn ->
          send_json_array(conn, ["c", "d"], 2, 2, 5)

        %Conn{query_params: %{"page" => "3", "per_page" => "2"}} = conn ->
          send_json_array(conn, ["e"], 3, 2, 5)

        # page = 1 default
        %Conn{query_params: %{"per_page" => "2"}} = conn ->
          send_json_array(conn, ["a", "b"], 1, 2, 5)
      end)

      assert ["a", "b", "c", "d", "e"] =
               PandascoreAPI.get_all!("/fake_route",
                 plug: {Req.Test, PaginationTest},
                 params: [per_page: 2]
               )

      assert_raise ArgumentError, fn ->
        PandascoreAPI.get_all!("/fake_route",
          plug: {Req.Test, PaginationTest},
          params: [per_page: 2, page: 2]
        )
      end
    end

    test "raises on non-success responses" do
      Req.Test.stub(ErrorTest, fn %Conn{} = conn ->
        conn
        |> Conn.put_resp_header("content-type", "application/json")
        |> Conn.resp(500, ~s({"error": "BoomError", "message":"boom"}))
      end)

      error =
        assert_raise PandascoreAPI.Error, fn ->
          PandascoreAPI.get_all!("/fake_route", plug: {Req.Test, ErrorTest})
        end

      assert error.status == 500
      assert error.url =~ "/fake_route"
      assert Exception.message(error) =~ "boom"
    end
  end

  describe "get_lol_matches_for_n_days/1" do
    test "caches results" do
      Req.Test.expect(CacheTest, 1, fn %Conn{} = conn ->
        lol_matches =
          "test/support/data/pandascore_api/lol_matches_7_days.json"
          |> File.read!()
          |> Jason.decode!()

        send_json_array(conn, lol_matches, 1, 100, length(lol_matches))
      end)

      assert {:ok, [%{} | _]} =
               PandascoreAPI.get_lol_matches_for_n_days(3, plug: {Req.Test, CacheTest})

      # Req.Test.expect expects only one call
      assert {:ok, [%{} | _]} =
               PandascoreAPI.get_lol_matches_for_n_days(3, plug: {Req.Test, CacheTest})
    end
  end

  describe "get_cs_matches_for_n_days/1" do
    test "caches results" do
      Req.Test.expect(CacheTest, 1, fn %Conn{} = conn ->
        cs_matches =
          "test/support/data/pandascore_api/cs_matches_7_days.json"
          |> File.read!()
          |> Jason.decode!()

        send_json_array(conn, cs_matches, 1, 100, length(cs_matches))
      end)

      assert {:ok, [%{} | _]} =
               PandascoreAPI.get_cs_matches_for_n_days(5, plug: {Req.Test, CacheTest})

      # Req.Test.expect expects only one call
      assert {:ok, [%{} | _]} =
               PandascoreAPI.get_cs_matches_for_n_days(5, plug: {Req.Test, CacheTest})
    end
  end

  defp send_json_array(%Conn{} = conn, data, page, per_page, total) do
    conn
    |> Conn.put_resp_header("x-total", to_string(total))
    |> Conn.put_resp_header("x-page", to_string(page))
    |> Conn.put_resp_header("x-per-page", to_string(per_page))
    |> Conn.put_resp_header(
      "link",
      [
        if page > 1 do
          ~s(<#{url(conn)}?page=1&per_page=#{per_page}>; rel="first")
        end,
        if page * per_page < total do
          ~s(<#{url(conn)}?page=#{page + 1}&per_page=#{per_page}>; rel="next")
        end,
        if page < div(total, per_page) do
          ~s(<#{url(conn)}?page=#{div(total, per_page)}&per_page=#{per_page}>; rel="last")
        end,
        if page > 1 do
          ~s(<#{url(conn)}?page=#{page - 1}&per_page=#{per_page}>; rel="prev")
        end
      ]
      |> Enum.filter(& &1)
      |> Enum.join(", ")
      |> IO.inspect(label: "Generated test link header")
    )
    |> Req.Test.json(data)
  end

  defp url(%Conn{} = conn) do
    conn
    |> Conn.request_url()
    |> String.split("?")
    |> hd()
  end
end
