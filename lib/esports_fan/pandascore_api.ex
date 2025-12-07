defmodule EsportsFan.PandascoreAPI do
  defmodule Error do
    defexception [:url, :status, :body]

    def message(err) do
      api_error_msg =
        case err.body do
          %{"error" => error, "message" => msg} -> " #{error}: #{msg}"
          _ -> ""
        end

      "Request to #{err.url} failed with status #{err.status}.#{api_error_msg}"
    end
  end

  require Logger

  @base_url "https://api.pandascore.co"
  @tournament_tiers ["s", "a", "b", "c"]

  @doc """
  Fetches League of Legends matches for the past and next `n_days`.

  Returns matches only from tournaments of relevant tiers.
  """
  def get_lol_matches_for_n_days(n_days) do
    get_matches_for_n_days("lol", n_days)
  end

  @doc """
  Fetches Counter-Strike 2 matches for the past and next `n_days`.

  Returns matches only from tournaments of relevant tiers.
  """
  def get_cs_matches_for_n_days(n_days) do
    get_matches_for_n_days("csgo", n_days)
  end

  defp get_matches_for_n_days(videogame_prefix, n_days) do
    now = DateTime.utc_now()
    past_date = DateTime.add(now, -n_days, :day)
    future_date = DateTime.add(now, n_days, :day)

    matches =
      get_all!("/#{videogame_prefix}/matches",
        params: [
          "range[begin_at]":
            "#{DateTime.to_iso8601(past_date)},#{DateTime.to_iso8601(future_date)}",
          "filter[opponents_filled]": true
        ]
      )

    targeted_matches =
      Enum.filter(matches, fn m -> m["tournament"]["tier"] in @tournament_tiers end)

    targeted_matches
  end

  @doc """
  Fetches all items from a paginated Pandascore API endpoint.
  """
  @spec get_all!(String.t(), Keyword.t()) :: list()
  def get_all!(url, req_options \\ []) do
    if get_in(req_options, [:params, :page]) do
      raise ArgumentError, "get_all! does not accept a :page parameter"
    end

    Stream.resource(
      fn ->
        {build_client()
         |> Req.merge(url: url)
         |> Req.merge(req_options), 0}
      end,
      &fetch_next_page/1,
      &Function.identity/1
    )
    |> Enum.to_list()
  end

  defp build_client do
    api_key = Application.fetch_env!(:esports_fan, __MODULE__)[:api_key]

    Req.new(
      base_url: @base_url,
      auth: {:bearer, api_key}
    )
  end

  defp fetch_next_page(nil), do: {:halt, nil}

  defp fetch_next_page({%Req.Request{}, 4}) do
    Logger.warning("Reached 4 pages of pagination, stopping to avoid excessive requests.")
    {:halt, nil}
  end

  defp fetch_next_page({%Req.Request{} = client, page_count}) do
    Logger.debug("Fetching page: #{inspect(client.url)}")

    case Req.get!(client) do
      %Req.Response{status: status, body: body, headers: headers} when status in 200..299 ->
        Logger.debug("Fetched page. Headers: #{inspect(headers, pretty: true)}")

        links = parse_link_header(headers["link"] || [])

        case Map.get(links, "next") do
          nil -> {body, nil}
          next_url -> {body, {Req.merge(client, url: next_url), page_count + 1}}
        end

      %Req.Response{status: status, body: body} ->
        raise Error, url: to_string(client.url), status: status, body: body
    end
  end

  defp parse_link_header([link_header]) do
    link_header
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(%{}, fn part, acc ->
      case Regex.run(~r/<([^>]+)>;\s*rel="([^"]+)"/, part) do
        [_, url, rel] -> Map.put(acc, rel, url)
        _ -> acc
      end
    end)
  end

  defp parse_link_header([]), do: %{}
end
