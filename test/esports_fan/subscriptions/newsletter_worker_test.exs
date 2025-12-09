defmodule EsportsFan.Subscriptions.NewsletterWorkerTest do
  use EsportsFan.DataCase
  use Oban.Testing, repo: EsportsFan.Repo

  alias EsportsFan.AccountsFixtures
  alias EsportsFan.Subscriptions.NewsletterWorker
  alias EsportsFan.Subscriptions
  import Swoosh.TestAssertions

  setup do
    user = AccountsFixtures.user_fixture(email: "with_sub@test.fake")

    {:ok, _} =
      Subscriptions.create_user_subscription(
        EsportsFan.Accounts.Scope.for_user(user),
        %{
          target_type: :videogame,
          target_id_or_slug: "league-of-legends",
          frequency_days: Subscriptions.default_frequency_days()
        }
      )

    receive_mail()

    no_sub_user = AccountsFixtures.user_fixture(email: "no_sub@toto.com")
    receive_mail()

    %{user: user, no_sub_user: no_sub_user}
  end

  test "sends and schedules newsletter email when user has subscriptions", %{user: user} do
    assert {:ok, _} = perform_job(NewsletterWorker, %{"user_id" => user.id})

    assert_email_sent(fn
      %{subject: "Your e-sports news", from: {_, "newsletter@esportsfan.gg"}} -> true
      _ -> false
    end)

    assert_enqueued worker: NewsletterWorker, args: %{"user_id" => user.id}
  end

  test "does not send & schedule newsletter email when user has no subscriptions", %{
    no_sub_user: user
  } do
    assert {:ok, _} = perform_job(NewsletterWorker, %{"user_id" => user.id})
    refute_email_sent()
    refute_enqueued worker: NewsletterWorker, args: %{"user_id" => user.id}
  end

  test "does not insert duplicate scheduled jobs", %{user: user} do
    # First job should be inserted
    assert {:ok, job} = perform_job(NewsletterWorker, %{"user_id" => user.id})
    assert_enqueued worker: NewsletterWorker, args: %{"user_id" => user.id}
    job_id = job.id

    # Second job should not create a duplicate
    assert {:ok, %Oban.Job{conflict?: true}} =
             perform_job(NewsletterWorker, %{"user_id" => user.id})

    assert [%{id: ^job_id}] = all_enqueued(worker: NewsletterWorker)
  end

  defp receive_mail do
    receive do
      {:email, email} -> email
    after
      100 -> nil
    end
  end
end
