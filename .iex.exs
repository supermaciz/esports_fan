import Ecto.Query
alias EsportsFan.Repo
alias EsportsFan.Subscriptions.UserSubscription
alias EsportsFan.Accounts.User

defmodule MyHelpers do
  @doc """
  Inserts Oban jobs to send newsletters to the given list of user IDs.
  """
  def insert_jobs(user_ids) do
    Enum.each(user_ids, fn user_id ->
      %{user_id: user_id}
      |> EsportsFan.Subscriptions.NewsletterWorker.new()
      |> Oban.insert!()
    end)
  end
end
