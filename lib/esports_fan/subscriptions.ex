defmodule EsportsFan.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias EsportsFan.Repo

  alias EsportsFan.Subscriptions.UserSubscription
  alias EsportsFan.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any user_subscription changes.

  The broadcasted messages match the pattern:

    * {:created, %UserSubscription{}}
    * {:updated, %UserSubscription{}}
    * {:deleted, %UserSubscription{}}

  """
  def subscribe_user_subscriptions(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(EsportsFan.PubSub, "user:#{key}:user_subscriptions")
  end

  defp broadcast_user_subscription(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(EsportsFan.PubSub, "user:#{key}:user_subscriptions", message)
  end

  @doc """
  Returns the list of user_subscriptions.

  ## Examples

      iex> list_user_subscriptions(scope)
      [%UserSubscription{}, ...]

  """
  def list_user_subscriptions(%Scope{} = scope) do
    Repo.all_by(UserSubscription, user_id: scope.user.id)
  end

  @doc """
  Gets a single user_subscription.

  Raises `Ecto.NoResultsError` if the User subscription does not exist.

  ## Examples

      iex> get_user_subscription!(scope, 123)
      %UserSubscription{}

      iex> get_user_subscription!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_user_subscription!(%Scope{} = scope, id) do
    Repo.get_by!(UserSubscription, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a user_subscription.

  ## Examples

      iex> create_user_subscription(scope, %{field: value})
      {:ok, %UserSubscription{}}

      iex> create_user_subscription(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_subscription(%Scope{} = scope, attrs) do
    with {:ok, user_subscription = %UserSubscription{}} <-
           %UserSubscription{}
           |> UserSubscription.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_user_subscription(scope, {:created, user_subscription})

      %{user_id: scope.user.id}
      |> EsportsFan.Subscriptions.NewsletterWorker.new()
      |> Oban.insert()

      {:ok, user_subscription}
    end
  end

  @doc """
  Updates a user_subscription.

  ## Examples

      iex> update_user_subscription(scope, user_subscription, %{field: new_value})
      {:ok, %UserSubscription{}}

      iex> update_user_subscription(scope, user_subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_subscription(%Scope{} = scope, %UserSubscription{} = user_subscription, attrs) do
    true = user_subscription.user_id == scope.user.id

    with {:ok, user_subscription = %UserSubscription{}} <-
           user_subscription
           |> UserSubscription.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_user_subscription(scope, {:updated, user_subscription})
      {:ok, user_subscription}
    end
  end

  @doc """
  Deletes a user_subscription.

  ## Examples

      iex> delete_user_subscription(scope, user_subscription)
      {:ok, %UserSubscription{}}

      iex> delete_user_subscription(scope, user_subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_subscription(%Scope{} = scope, %UserSubscription{} = user_subscription) do
    true = user_subscription.user_id == scope.user.id

    with {:ok, user_subscription = %UserSubscription{}} <-
           Repo.delete(user_subscription) do
      broadcast_user_subscription(scope, {:deleted, user_subscription})
      {:ok, user_subscription}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_subscription changes.

  ## Examples

      iex> change_user_subscription(scope, user_subscription)
      %Ecto.Changeset{data: %UserSubscription{}}

  """
  def change_user_subscription(
        %Scope{} = scope,
        %UserSubscription{} = user_subscription,
        attrs \\ %{}
      ) do
    true = user_subscription.user_id == scope.user.id

    UserSubscription.changeset(user_subscription, attrs, scope)
  end

  def default_frequency_days do
    7
  end
end
