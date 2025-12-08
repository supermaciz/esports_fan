defmodule EsportsFan.Repo.Migrations.CreateUserSubscriptions do
  use Ecto.Migration

  def change do
    create table(:user_subscriptions) do
      add :target_type, :string
      add :target_id_or_slug, :string
      add :frequency_days, :integer
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:user_subscriptions, [:user_id])
  end
end
