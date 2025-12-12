defmodule EsportsFanWeb.HomeLive do
  use EsportsFanWeb, :surface_live_view

  alias EsportsFanWeb.Components.TitleComponent

  def render(assigns) do
    ~F"""
    <TitleComponent>
      EsportsFan
    </TitleComponent>
    <p>Your go-to source for personalized esports news and updates!</p>
    """
  end
end
