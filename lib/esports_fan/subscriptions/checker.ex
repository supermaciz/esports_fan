defmodule EsportsFan.Subscriptions.Checker do
  use Oban.Worker
  import Ecto.Query
  alias EsportsFan.Repo
  alias EsportsFan.Subscriptions.UserSubscription

  @impl Oban.Worker
  def perform(_job) do
    query =
      from us in UserSubscription,
        join: u in assoc(us, :user),
        group_by: [us.user_id, us.id, u.email],
        select: {u.email, us}

    Repo.all(query)
    |> Enum.each(fn {email, user_subscription} ->
      # Logic for sending mail goes here
      # Another job could be enqueued here to handle the email sending
      IO.puts(
        "Would send subscription email to #{email} for subscription to #{user_subscription.target_type} #{user_subscription.target_id_or_slug}"
      )
    end)

    :ok
  end
end
