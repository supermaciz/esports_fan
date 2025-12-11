defmodule EsportsFan.Subscriptions.UserSubscription do
  @moduledoc """
  Schema for a user's subscription to esports results for a player, a team,
  or a videogame.

  Used to generate personalized newsletter content.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias EsportsFan.Accounts.User

  schema "user_subscriptions" do
    field :target_type, Ecto.Enum, values: [:player, :team, :videogame]
    field :target_id_or_slug, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_subscription, attrs, user_scope) do
    user_subscription
    |> cast(attrs, [:target_type, :target_id_or_slug])
    |> validate_required([:target_type, :target_id_or_slug])
    |> put_change(:user_id, user_scope.user.id)
  end
end
