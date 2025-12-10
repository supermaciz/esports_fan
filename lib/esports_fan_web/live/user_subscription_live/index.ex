defmodule EsportsFanWeb.UserSubscriptionLive.Index do
  use EsportsFanWeb, :live_view

  alias EsportsFan.Subscriptions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing User subscriptions
        <:actions>
          <.button variant="primary" navigate={~p"/user_subscriptions/new"}>
            <.icon name="hero-plus" /> New User subscription
          </.button>
        </:actions>
      </.header>

      <.table
        id="user_subscriptions"
        rows={@streams.user_subscriptions}
        row_click={
          fn {_id, user_subscription} -> JS.navigate(~p"/user_subscriptions/#{user_subscription}") end
        }
      >
        <:col :let={{_id, user_subscription}} label="Target type">
          {user_subscription.target_type}
        </:col>
        <:col :let={{_id, user_subscription}} label="Target id or slug">
          {user_subscription.target_id_or_slug}
        </:col>
        <:col :let={{_id, user_subscription}} label="Frequency days">
          {user_subscription.frequency_days}
        </:col>
        <:action :let={{_id, user_subscription}}>
          <div class="sr-only">
            <.link navigate={~p"/user_subscriptions/#{user_subscription}"}>Show</.link>
          </div>
          <.link navigate={~p"/user_subscriptions/#{user_subscription}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, user_subscription}}>
          <.link
            phx-click={JS.push("delete", value: %{id: user_subscription.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Subscriptions.subscribe_user_subscriptions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing User subscriptions")
     |> stream(:user_subscriptions, list_user_subscriptions(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_subscription = Subscriptions.get_user_subscription!(socket.assigns.current_scope, id)

    {:ok, _} =
      Subscriptions.delete_user_subscription(socket.assigns.current_scope, user_subscription)

    {:noreply, stream_delete(socket, :user_subscriptions, user_subscription)}
  end

  @impl true
  def handle_info({type, %EsportsFan.Subscriptions.UserSubscription{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :user_subscriptions, list_user_subscriptions(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_user_subscriptions(current_scope) do
    Subscriptions.list_user_subscriptions(current_scope)
  end
end
