defmodule EsportsFan.Subscriptions.UserSubscription do
  use Ecto.Schema
  import Ecto.Changeset
  alias EsportsFan.Accounts.User

  schema "user_subscriptions" do
    field :target_type, Ecto.Enum, values: [:player, :team, :videogame]
    field :target_id_or_slug, :string
    field :frequency_days, :integer
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_subscription, attrs, user_scope) do
    user_subscription
    |> cast(attrs, [:target_type, :target_id_or_slug, :frequency_days])
    |> validate_required([:target_type, :target_id_or_slug, :frequency_days])
    |> put_change(:user_id, user_scope.user.id)
  end
end
