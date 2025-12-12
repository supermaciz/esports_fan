defmodule EsportsFanWeb.UserSubscriptionLive.Form do
  use EsportsFanWeb, :live_view

  alias EsportsFan.Subscriptions
  alias EsportsFan.Subscriptions.UserSubscription

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage user_subscription records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="user_subscription-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:target_type]}
          type="select"
          label="Target type"
          options={["videogame"]}
        />
        <.input
          field={@form[:target_id_or_slug]}
          type="select"
          label="Video game"
          prompt="Select a video game"
          options={[{"LoL", "league-of-legends"}, {"Counter-Strike", "cs-go"}]}
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save newsletter subject</.button>
          <.button navigate={return_path(@current_scope, @return_to, @user_subscription)}>
            Cancel
          </.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    user_subscription = Subscriptions.get_user_subscription!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit User subscription")
    |> assign(:user_subscription, user_subscription)
    |> assign(
      :form,
      to_form(
        Subscriptions.change_user_subscription(socket.assigns.current_scope, user_subscription)
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    user_subscription = %UserSubscription{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "Newsletter subject subscription")
    |> assign(:user_subscription, user_subscription)
    |> assign(
      :form,
      to_form(
        Subscriptions.change_user_subscription(socket.assigns.current_scope, user_subscription)
      )
    )
  end

  @impl true
  def handle_event("validate", %{"user_subscription" => user_subscription_params}, socket) do
    changeset =
      Subscriptions.change_user_subscription(
        socket.assigns.current_scope,
        socket.assigns.user_subscription,
        user_subscription_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user_subscription" => user_subscription_params}, socket) do
    save_user_subscription(socket, socket.assigns.live_action, user_subscription_params)
  end

  defp save_user_subscription(socket, :edit, user_subscription_params) do
    case Subscriptions.update_user_subscription(
           socket.assigns.current_scope,
           socket.assigns.user_subscription,
           user_subscription_params
         ) do
      {:ok, user_subscription} ->
        {:noreply,
         socket
         |> put_flash(:info, "User subscription updated successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               user_subscription
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user_subscription(socket, :new, user_subscription_params) do
    case Subscriptions.create_user_subscription(
           socket.assigns.current_scope,
           user_subscription_params
         ) do
      {:ok, user_subscription} ->
        {:noreply,
         socket
         |> put_flash(:info, "User subscription created successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               user_subscription
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _user_subscription), do: ~p"/user_subscriptions"
end
