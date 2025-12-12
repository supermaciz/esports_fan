defmodule EsportsFanWeb.ExampleLive do
  use EsportsFanWeb, :surface_live_view

  alias EsportsFanWeb.Components.ExampleComponent

  def render(assigns) do
    ~F"""
    <ExampleComponent>
      Hi there!
    </ExampleComponent>
    """
  end
end
