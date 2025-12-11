defmodule EsportsFan.Subscriptions.EmailTest do
  use ExUnit.Case, async: true
  alias EsportsFan.Subscriptions.UserSubscription
  alias EsportsFan.Accounts.User

  setup do
    Req.Test.stub(DefaultPandascoreStub, EsportsFan.PandascoreAPI.MockPlug)

    lol_user = %User{
      id: 1,
      email: "lol@test.com",
      user_subscriptions: [
        %UserSubscription{
          target_type: :videogame,
          target_id_or_slug: "league-of-legends"
        }
      ]
    }

    cs_user = %User{
      id: 2,
      email: "cs@test.com",
      user_subscriptions: [
        %UserSubscription{
          target_type: :videogame,
          target_id_or_slug: "cs-go"
        }
      ]
    }

    lol_cs_user = %User{
      id: 3,
      email: "cs-lol@test.gg",
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
    }

    {:ok, lol_user: lol_user, cs_user: cs_user, lol_cs_user: lol_cs_user}
  end

  describe "newsletter/2 builds an email with correct body" do
    test "for League of Legends subscription", %{lol_user: user} do
      %Swoosh.Email{html_body: email_body} =
        EsportsFan.Subscriptions.Email.newsletter(user.email, user.user_subscriptions)

      assert email_body =~ "<h2>News about LoL</h2>"
      refute email_body =~ "<h2>News about Counter-Strike</h2>"
    end

    test "for Counter-Strike subscription", %{cs_user: user} do
      %Swoosh.Email{html_body: email_body} =
        EsportsFan.Subscriptions.Email.newsletter(user.email, user.user_subscriptions)

      assert email_body =~ "<h2>News about Counter-Strike</h2>"
      refute email_body =~ "<h2>News about LoL</h2>"
    end

    test "for both LoL and CS subscriptions", %{lol_cs_user: user} do
      %Swoosh.Email{html_body: email_body} =
        EsportsFan.Subscriptions.Email.newsletter(user.email, user.user_subscriptions)

      assert email_body =~ "<h2>News about LoL</h2>"
      assert email_body =~ "<h2>News about Counter-Strike</h2>"
    end
  end
end
