defmodule EsportsFan.SubscriptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EsportsFan.Subscriptions` context.
  """

  @doc """
  Generate a user_subscription.
  """
  def user_subscription_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        target_id_or_slug: "league-of-legends",
        target_type: :videogame
      })

    {:ok, user_subscription} = EsportsFan.Subscriptions.create_user_subscription(scope, attrs)
    user_subscription
  end
end
