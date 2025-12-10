defmodule EsportsFanWeb.UserSubscriptionLive.Show do
  use EsportsFanWeb, :live_view

  alias EsportsFan.Subscriptions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        User subscription {@user_subscription.id}
        <:subtitle>This is a user_subscription record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/user_subscriptions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/user_subscriptions/#{@user_subscription}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit user_subscription
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Target type">{@user_subscription.target_type}</:item>
        <:item title="Target id or slug">{@user_subscription.target_id_or_slug}</:item>
        <:item title="Frequency days">{@user_subscription.frequency_days}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Subscriptions.subscribe_user_subscriptions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show User subscription")
     |> assign(
       :user_subscription,
       Subscriptions.get_user_subscription!(socket.assigns.current_scope, id)
     )}
  end

  @impl true
  def handle_info(
        {:updated, %EsportsFan.Subscriptions.UserSubscription{id: id} = user_subscription},
        %{assigns: %{user_subscription: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :user_subscription, user_subscription)}
  end

  def handle_info(
        {:deleted, %EsportsFan.Subscriptions.UserSubscription{id: id}},
        %{assigns: %{user_subscription: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current user_subscription was deleted.")
     |> push_navigate(to: ~p"/user_subscriptions")}
  end

  def handle_info({type, %EsportsFan.Subscriptions.UserSubscription{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
