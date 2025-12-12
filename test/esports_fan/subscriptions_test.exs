defmodule EsportsFan.SubscriptionsTest do
  use EsportsFan.DataCase

  alias EsportsFan.Subscriptions

  describe "user_subscriptions" do
    alias EsportsFan.Subscriptions.UserSubscription

    import EsportsFan.AccountsFixtures, only: [user_scope_fixture: 0]
    import EsportsFan.SubscriptionsFixtures

    @invalid_attrs %{target_type: nil, target_id_or_slug: nil}

    test "list_user_subscriptions/1 returns all scoped user_subscriptions" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      user_subscription = user_subscription_fixture(scope)
      other_user_subscription = user_subscription_fixture(other_scope)
      assert Subscriptions.list_user_subscriptions(scope) == [user_subscription]
      assert Subscriptions.list_user_subscriptions(other_scope) == [other_user_subscription]
    end

    test "get_user_subscription!/2 returns the user_subscription with given id" do
      scope = user_scope_fixture()
      user_subscription = user_subscription_fixture(scope)
      other_scope = user_scope_fixture()

      assert Subscriptions.get_user_subscription!(scope, user_subscription.id) ==
               user_subscription

      assert_raise Ecto.NoResultsError, fn ->
        Subscriptions.get_user_subscription!(other_scope, user_subscription.id)
      end
    end

    test "create_user_subscription/2 with valid data creates a user_subscription" do
      valid_attrs = %{
        target_type: :player,
        target_id_or_slug: "some target_id_or_slug"
      }

      scope = user_scope_fixture()

      assert {:ok, %UserSubscription{} = user_subscription} =
               Subscriptions.create_user_subscription(scope, valid_attrs)

      assert user_subscription.target_type == :player
      assert user_subscription.target_id_or_slug == "some target_id_or_slug"
      assert user_subscription.user_id == scope.user.id
    end

    test "create_user_subscription/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Subscriptions.create_user_subscription(scope, @invalid_attrs)
    end

    test "create_user_subscription/2 returns unique constraint error on duplicates" do
      scope = user_scope_fixture()
      _existing = user_subscription_fixture(scope)

      assert {:error, changeset} =
               Subscriptions.create_user_subscription(scope, %{
                 target_type: :videogame,
                 target_id_or_slug: "league-of-legends"
               })

      assert %{target_id_or_slug: ["You are already subscribed to this subject."]} =
               errors_on(changeset)
    end

    test "update_user_subscription/3 with valid data updates the user_subscription" do
      scope = user_scope_fixture()
      user_subscription = user_subscription_fixture(scope)

      update_attrs = %{
        target_type: :team,
        target_id_or_slug: "some updated target_id_or_slug"
      }

      assert {:ok, %UserSubscription{} = user_subscription} =
               Subscriptions.update_user_subscription(scope, user_subscription, update_attrs)

      assert user_subscription.target_type == :team
      assert user_subscription.target_id_or_slug == "some updated target_id_or_slug"
    end

    test "update_user_subscription/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      user_subscription = user_subscription_fixture(scope)

      assert_raise MatchError, fn ->
        Subscriptions.update_user_subscription(other_scope, user_subscription, %{})
      end
    end

    test "update_user_subscription/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      user_subscription = user_subscription_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Subscriptions.update_user_subscription(scope, user_subscription, @invalid_attrs)

      assert user_subscription ==
               Subscriptions.get_user_subscription!(scope, user_subscription.id)
    end

    test "delete_user_subscription/2 deletes the user_subscription" do
      scope = user_scope_fixture()
      user_subscription = user_subscription_fixture(scope)

      assert {:ok, %UserSubscription{}} =
               Subscriptions.delete_user_subscription(scope, user_subscription)

      assert_raise Ecto.NoResultsError, fn ->
        Subscriptions.get_user_subscription!(scope, user_subscription.id)
      end
    end

    test "delete_user_subscription/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      user_subscription = user_subscription_fixture(scope)

      assert_raise MatchError, fn ->
        Subscriptions.delete_user_subscription(other_scope, user_subscription)
      end
    end

    test "change_user_subscription/2 returns a user_subscription changeset" do
      scope = user_scope_fixture()
      user_subscription = user_subscription_fixture(scope)
      assert %Ecto.Changeset{} = Subscriptions.change_user_subscription(scope, user_subscription)
    end
  end
end
