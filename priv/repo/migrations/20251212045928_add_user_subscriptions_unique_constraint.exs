defmodule EsportsFan.Repo.Migrations.AddUserSubscriptionsUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:user_subscriptions, [:user_id, :target_type, :target_id_or_slug],
             name: :unique_user_subscription_per_target
           )
  end
end
