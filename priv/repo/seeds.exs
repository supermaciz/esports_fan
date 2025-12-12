# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EsportsFan.Repo.insert!(%EsportsFan.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias EsportsFan.Repo
alias EsportsFan.Accounts.User
alias EsportsFan.Subscriptions.UserSubscription

hashed_password = Argon2.hash_pwd_salt("password")
now = DateTime.utc_now() |> DateTime.truncate(:second)

Enum.each(1..10000, fn i ->
  Repo.insert!(%User{
    email: "fake_user#{i}@example.com",
    hashed_password: hashed_password,
    confirmed_at: now,
    user_subscriptions: [
      %UserSubscription{
        target_type: :videogame,
        target_id_or_slug: "league-of-legends"
      }
    ]
  })
end)

Enum.each(10001..15000, fn i ->
  Repo.insert!(%User{
    email: "fake_user#{i}@example.com",
    hashed_password: hashed_password,
    confirmed_at: now,
    user_subscriptions: [
      %UserSubscription{
        target_type: :videogame,
        target_id_or_slug: "cs-go"
      }
    ]
  })
end)

Enum.each(15001..20000, fn i ->
  Repo.insert!(%User{
    email: "fake_user#{i}@example.com",
    hashed_password: hashed_password,
    confirmed_at: now,
    user_subscriptions: [
      %UserSubscription{
        target_type: :videogame,
        target_id_or_slug: "league-of-legends"
      },
      %UserSubscription{
        target_type: :videogame,
        target_id_or_slug: "cs-go"
      }
    ]
  })
end)
