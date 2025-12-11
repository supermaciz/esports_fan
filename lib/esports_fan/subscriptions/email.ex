defmodule EsportsFan.Subscriptions.Email do
  import Swoosh.Email
  alias EsportsFan.Subscriptions.UserSubscription

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

    #{Enum.map_join(subscriptions, "\n", &build_section/1)}
    """
  end

  defp build_section(%UserSubscription{target_type: :videogame, target_id_or_slug: slug}) do
    """
    <h2>News about #{slug}</h2>
    <p>...</p>
    """
  end

  defp build_section(%UserSubscription{target_type: :team, target_id_or_slug: slug}) do
    """
    <h2>News about team #{slug}</h2>
    <p>...</p>
    """
  end

  defp build_section(%UserSubscription{target_type: :player, target_id_or_slug: slug}) do
    """
    <h2>News about player #{slug}</h2>
    <p>...</p>
    """
  end
end
