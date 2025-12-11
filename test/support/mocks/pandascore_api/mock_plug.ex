defmodule EsportsFan.PandascoreAPI.MockPlug do
  @moduledoc """
  A Req.Test plug that mocks Pandascore API responses for tests.

  Does not handle pagination and links header.
  Returns all data in a single response.
  """
  alias Plug.Conn

  def init(opts), do: opts

  def call(%Conn{path_info: ["lol", "matches"]} = conn, _opts) do
    lol_matches =
      "test/support/data/pandascore_api/lol_matches_7_days.json"
      |> File.read!()
      |> Jason.decode!()

    send_json_array(conn, lol_matches)
  end

  def call(%Conn{path_info: ["csgo", "matches"]} = conn, _opts) do
    cs_matches =
      "test/support/data/pandascore_api/cs_matches_7_days.json"
      |> File.read!()
      |> Jason.decode!()

    send_json_array(conn, cs_matches)
  end

  defp send_json_array(%Conn{} = conn, data) do
    len = length(data)

    conn
    |> Conn.put_resp_header("x-total", to_string(len))
    |> Conn.put_resp_header("x-page", "1")
    |> Conn.put_resp_header("x-per-page", to_string(len))
    |> Req.Test.json(data)
  end
end
