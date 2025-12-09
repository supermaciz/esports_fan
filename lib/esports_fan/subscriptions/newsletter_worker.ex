defmodule EsportsFan.Subscriptions.NewsletterWorker do
  alias EsportsFan.Subscriptions
  alias EsportsFan.Accounts.Scope
  use Oban.Worker, queue: :emails, max_attempts: 3

  @impl true
  def perform(%{args: %{"user_id" => user_id}, attempt: 1} = job) do
    user = EsportsFan.Accounts.get_user!(user_id)

    case get_subs(user) do
      [] ->
        {:ok, :no_newsletter_sent}

      subs ->
        send_newsletter(user, subs)
        schedule_next_newsletter(job, user_id)
    end
  end

  def perform(%{args: %{"user_id" => user_id}}) do
    user = EsportsFan.Accounts.get_user!(user_id)

    case get_subs(user) do
      [] ->
        {:ok, :no_newsletter_sent}

      subs ->
        send_newsletter(user, subs)
    end
  end

  defp send_newsletter(user, subs) do
    email = Subscriptions.Email.newsletter(user.email, subs)
    EsportsFan.Mailer.deliver(email)
  end

  defp schedule_next_newsletter(job, user_id) do
    job.args
    |> new(
      schedule_in: {Subscriptions.default_frequency_days(), :day},
      meta: %{user_id: user_id},
      tags: ["newsletter", "user:#{user_id}"]
    )
    |> Oban.insert()
  end

  defp get_subs(user) do
    scope = Scope.for_user(user)
    Subscriptions.list_user_subscriptions(scope)
  end
end
