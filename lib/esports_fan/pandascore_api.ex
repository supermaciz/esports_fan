defmodule EsportsFan.PandascoreAPI do
  require Logger

  defmodule Data do
    defstruct [:last_matches, :upcoming_matches, :n_days]
  end

  @base_url "https://api.pandascore.co"

  def get_lol_matches_for_n_days(n_days) do
    get_matches_for_n_days("lol", n_days)
  end

  def get_cs_matches_for_n_days(n_days) do
    get_matches_for_n_days("csgo", n_days)
  end

  @spec get(String.t(), map | Keyword.t()) :: {:error, String.t()} | {:ok, any()}
  def get(url, query_params) do
    client = build_client() |> Req.merge(url: url, params: query_params)
    Logger.info("Fetching data from Pandascore API: #{client.url}")

    case Req.get(client) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error,
         "Failed to fetch data. Status code: #{status}. #{body["error"]}: #{body["message"]}"}

      {:error, reason} ->
        {:error, "Request failed: #{reason}"}
    end
  end

  defp get_matches_for_n_days(videogame_prefix, n_days) do
    now = DateTime.utc_now()
    past_date = DateTime.add(now, -n_days, :day)
    future_date = DateTime.add(now, n_days, :day)

    get("/#{videogame_prefix}/matches", %{
      "range[begin_at]" => "#{Date.to_iso8601(past_date)},#{Date.to_iso8601(future_date)}",
      "filter[opponents_filled]" => true
      # "page[size]" => "50",
      # "filter[tier]" => @tournament_tiers
    })
  end

  defp build_client do
    api_key = Application.fetch_env!(:esports_fan, __MODULE__)[:api_key]

    Req.new(
      base_url: @base_url,
      auth: {:bearer, api_key}
    )
  end
end
