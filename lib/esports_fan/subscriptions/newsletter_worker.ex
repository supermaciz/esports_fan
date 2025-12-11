defmodule EsportsFan.Subscriptions.NewsletterWorker do
  @moduledoc """
  An Oban worker responsible for sending newsletter emails to users based
  on their subscriptions.

  This is a recursive job that mails and renews itself only if the user
  has subscriptions.
  """
  require Logger

  alias EsportsFan.Subscriptions
  alias EsportsFan.Accounts.Scope

  use Oban.Worker,
    queue: :emails,
    max_attempts: 3,
    unique: [
      period: 60 * 60 * 24 * Subscriptions.default_frequency_days(),
      fields: [:args, :worker],
      keys: [:user_id],
      states: [:scheduled, :available]
    ]

  @impl Oban.Worker
  def perform(%{args: %{"user_id" => user_id}, attempt: 1} = _job) do
    user = EsportsFan.Accounts.get_user!(user_id)
    Logger.metadata(user_id: user_id, user_email: user.email)
    Logger.debug("Performing newsletter job (first attempt)")

    case get_subs(user) do
      [] ->
        Logger.info("No subscriptions. Stopping newsletter.")
        {:ok, :no_newsletter_sent}

      subs ->
        with {:ok, job} <- schedule_next_newsletter(user_id),
             {:ok, _} <- send_newsletter(user, subs) do
          {:ok, job}
        end
    end
  end

  def perform(%{args: %{"user_id" => user_id}}) do
    user = EsportsFan.Accounts.get_user!(user_id)
    Logger.metadata(user_id: user_id, user_email: user.email)
    Logger.notice("Performing newsletter retry job")

    case get_subs(user) do
      [] ->
        Logger.info("No subscriptions. Stopping newsletter.")
        {:ok, :no_newsletter_sent}

      subs ->
        send_newsletter(user, subs)
    end
  end

  defp send_newsletter(user, subs) do
    Logger.info(
      "Sending newsletter email for subscriptions: [#{Enum.map_join(subs, ", ", & &1.target_id_or_slug)}]"
    )

    email = Subscriptions.Email.newsletter(user.email, subs)
    EsportsFan.Mailer.deliver(email)
  end

  defp schedule_next_newsletter(user_id) do
    Logger.info("Scheduling next newsletter")

    %{user_id: user_id}
    |> new(
      schedule_in: {Subscriptions.default_frequency_days(), :day},
      tags: ["newsletter", "user:#{user_id}", "auto-scheduled"]
    )
    |> Oban.insert()
  end

  defp get_subs(user) do
    scope = Scope.for_user(user)
    Subscriptions.list_user_subscriptions(scope)
  end
end
