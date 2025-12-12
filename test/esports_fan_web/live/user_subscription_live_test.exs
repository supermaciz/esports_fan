defmodule EsportsFanWeb.UserSubscriptionLiveTest do
  use EsportsFanWeb.ConnCase

  import Phoenix.LiveViewTest
  import EsportsFan.SubscriptionsFixtures

  setup :register_and_log_in_user

  defp create_user_subscription(%{scope: scope}) do
    user_subscription = user_subscription_fixture(scope)

    %{user_subscription: user_subscription}
  end

  describe "Index" do
    setup [:create_user_subscription]

    test "deletes user_subscription in listing", %{
      conn: conn,
      user_subscription: user_subscription
    } do
      {:ok, index_live, _html} = live(conn, ~p"/user_subscriptions")

      assert index_live
             |> element("#user_subscriptions-#{user_subscription.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#user_subscriptions-#{user_subscription.id}")
    end
  end

  describe "Form" do
    setup [:create_user_subscription]

    test "shows unique constraint error when submitting duplicate subject", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/user_subscriptions/new")

      duplicate_params = %{target_type: "videogame", target_id_or_slug: "league-of-legends"}

      assert view
             |> form("#user_subscription-form", user_subscription: duplicate_params)
             |> render_submit() =~ "You are already subscribed to this subject."
    end
  end
end
