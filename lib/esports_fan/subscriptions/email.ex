defmodule EsportsFan.Subscriptions.Email do
  import Swoosh.Email

  def newsletter(email, subscriptions) do
    new()
    |> to(email)
    |> from({"EsportsFan Newsletter", "newsletter@esportsfan.gg"})
    |> subject("Your e-sports news")
    |> html_body("TODO: implement newsletter HTML body")
    |> text_body("TODO: implement newsletter text body")
  end
end
