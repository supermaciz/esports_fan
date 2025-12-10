defmodule EsportsFan.Subscriptions.Email do
  import Swoosh.Email
  alias EsportsFan.Subscriptions

  def newsletter(email, _subscriptions) do
    new()
    |> to(email)
    |> from({"EsportsFan Newsletter", "newsletter@esportsfan.gg"})
    |> subject("Your e-sports news")
    |> html_body("TODO: implement newsletter HTML body")
    |> text_body("TODO: implement newsletter text body")
  end

  # defp build_section(%Subscriptions.UserSubscription{} = _sub) do

  # end
end
