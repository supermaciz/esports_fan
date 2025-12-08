defmodule EsportsFanWeb.UserSubscriptionLiveTest do
  use EsportsFanWeb.ConnCase

  import Phoenix.LiveViewTest
  import EsportsFan.SubscriptionsFixtures

  @create_attrs %{target_type: :player, target_id_or_slug: "some target_id_or_slug", frequency_days: 42}
  @update_attrs %{target_type: :team, target_id_or_slug: "some updated target_id_or_slug", frequency_days: 43}
  @invalid_attrs %{target_type: nil, target_id_or_slug: nil, frequency_days: nil}

  setup :register_and_log_in_user

  defp create_user_subscription(%{scope: scope}) do
    user_subscription = user_subscription_fixture(scope)

    %{user_subscription: user_subscription}
  end

  describe "Index" do
    setup [:create_user_subscription]

    test "lists all user_subscriptions", %{conn: conn, user_subscription: user_subscription} do
      {:ok, _index_live, html} = live(conn, ~p"/user_subscriptions")

      assert html =~ "Listing User subscriptions"
      assert html =~ user_subscription.target_id_or_slug
    end

    test "saves new user_subscription", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/user_subscriptions")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New User subscription")
               |> render_click()
               |> follow_redirect(conn, ~p"/user_subscriptions/new")

      assert render(form_live) =~ "New User subscription"

      assert form_live
             |> form("#user_subscription-form", user_subscription: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#user_subscription-form", user_subscription: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/user_subscriptions")

      html = render(index_live)
      assert html =~ "User subscription created successfully"
      assert html =~ "some target_id_or_slug"
    end

    test "updates user_subscription in listing", %{conn: conn, user_subscription: user_subscription} do
      {:ok, index_live, _html} = live(conn, ~p"/user_subscriptions")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#user_subscriptions-#{user_subscription.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/user_subscriptions/#{user_subscription}/edit")

      assert render(form_live) =~ "Edit User subscription"

      assert form_live
             |> form("#user_subscription-form", user_subscription: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#user_subscription-form", user_subscription: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/user_subscriptions")

      html = render(index_live)
      assert html =~ "User subscription updated successfully"
      assert html =~ "some updated target_id_or_slug"
    end

    test "deletes user_subscription in listing", %{conn: conn, user_subscription: user_subscription} do
      {:ok, index_live, _html} = live(conn, ~p"/user_subscriptions")

      assert index_live |> element("#user_subscriptions-#{user_subscription.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_subscriptions-#{user_subscription.id}")
    end
  end

  describe "Show" do
    setup [:create_user_subscription]

    test "displays user_subscription", %{conn: conn, user_subscription: user_subscription} do
      {:ok, _show_live, html} = live(conn, ~p"/user_subscriptions/#{user_subscription}")

      assert html =~ "Show User subscription"
      assert html =~ user_subscription.target_id_or_slug
    end

    test "updates user_subscription and returns to show", %{conn: conn, user_subscription: user_subscription} do
      {:ok, show_live, _html} = live(conn, ~p"/user_subscriptions/#{user_subscription}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/user_subscriptions/#{user_subscription}/edit?return_to=show")

      assert render(form_live) =~ "Edit User subscription"

      assert form_live
             |> form("#user_subscription-form", user_subscription: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#user_subscription-form", user_subscription: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/user_subscriptions/#{user_subscription}")

      html = render(show_live)
      assert html =~ "User subscription updated successfully"
      assert html =~ "some updated target_id_or_slug"
    end
  end
end
