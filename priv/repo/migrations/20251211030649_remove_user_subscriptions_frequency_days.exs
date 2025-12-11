defmodule EsportsFan.Repo.Migrations.RemoveUserSubscriptionsFrequencyDays do
  use Ecto.Migration

  def change do
    alter table(:user_subscriptions) do
      remove :frequency_days
    end
  end
end
