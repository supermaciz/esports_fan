defmodule EsportsFan.Subscriptions.Email do
  import Swoosh.Email
  alias EsportsFan.Subscriptions
  alias EsportsFan.Subscriptions.UserSubscription
  alias EsportsFan.PandascoreAPI

  @doc """
  Builds a newsletter email for the given email address and a list of
  subscriptions.

  Uses data from PandaScore to populate the newsletter content.
  """
  def newsletter(email, subscriptions) do
    new()
    |> to(email)
    |> from({"EsportsFan Newsletter", "newsletter@esportsfan.gg"})
    |> subject("Your e-sports news")
    |> html_body(build_body(subscriptions))
  end

  # defp build_section(%Subscriptions.UserSubscription{} = _sub) do

  # end

  defp build_body(subscriptions) do
    """
    <h1>Your e-sports news</h1>

    Here is the latest news based on your subscriptions.

    #{Enum.map_join(subscriptions, "\n<hr>", &build_section/1)}
    """
  end

  defp build_section(%UserSubscription{
         target_type: :videogame,
         target_id_or_slug: "league-of-legends"
       }) do
    {:ok, matches} =
      PandascoreAPI.get_lol_matches_for_n_days(Subscriptions.default_frequency_days())

    """
    <h2>News about LoL</h2>
    #{build_vg_subsection(matches)}
    """
  end

  defp build_section(%UserSubscription{target_type: :videogame, target_id_or_slug: "cs-go"}) do
    {:ok, matches} =
      PandascoreAPI.get_cs_matches_for_n_days(Subscriptions.default_frequency_days())

    """
    <h2>News about Counter-Strike</h2>
    #{build_vg_subsection(matches)}
    """
  end

  defp build_vg_subsection(matches) do
    past_matches = Enum.filter(matches, fn m -> m["status"] == "finished" end)
    upcoming_matches = Enum.filter(matches, fn m -> m["status"] == "not_started" end)
    running_matches = Enum.filter(matches, fn m -> m["status"] == "running" end)

    """
    <h3>Past Matches</h3>
    #{format_matches(past_matches)}

    <h3>Ongoing Matches</h3>
    #{format_matches(running_matches)}

    <h3>Upcoming Matches</h3>
    #{format_matches(upcoming_matches)}
    """
  end

  defp format_matches(matches) do
    Enum.map_join(matches, "\n", fn
      %{"status" => "finished"} = m ->
        """
        <p>
          #{m["opponents"] |> Enum.map(& &1["opponent"]["name"]) |> Enum.join(" vs ")} -
          <strong>#{m["league"]["name"]}</strong> -
          Final Score: #{Enum.map_join(m["results"], " - ", fn r -> r["score"] end)}
          <br/>
          Played at: #{format_datetime(m["begin_at"])}
        </p>
        """

      m ->
        """
        <p>
          #{m["opponents"] |> Enum.map(& &1["opponent"]["name"]) |> Enum.join(" vs ")} -
          #{m["league"]["name"]} -
          #{format_datetime(m["scheduled_at"])}
        </p>
        """
    end)
  end

  defp format_datetime(datetime_str) do
    with {:ok, datetime, _offset} <- DateTime.from_iso8601(datetime_str),
         {:ok, formatted} <- Timex.format(datetime, "{RFC1123}") do
      formatted
    else
      _ -> "N/A"
    end
  end
end
