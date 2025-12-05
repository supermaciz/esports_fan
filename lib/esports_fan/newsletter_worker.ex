defmodule EsportsFan.NewsletterWorker do
  use Oban.Worker, queue: :emails, max_attempts: 3

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Sending newsletter to users")

    :ok
  end
end
