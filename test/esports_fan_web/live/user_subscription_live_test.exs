defmodule EsportsFanWeb.UserSubscriptionLiveTest do
  use EsportsFanWeb.ConnCase

  import Phoenix.LiveViewTest
  import EsportsFan.SubscriptionsFixtures

  @create_attrs %{
    target_type: :player,
    target_id_or_slug: "some target_id_or_slug"
  }
  @update_attrs %{
    target_type: :team,
    target_id_or_slug: "some updated target_id_or_slug"
  }
  @invalid_attrs %{target_type: nil, target_id_or_slug: nil}

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
end
