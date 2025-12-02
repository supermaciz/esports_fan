defmodule EsportsFanWeb.ExampleLive do
  use Surface.LiveView

  alias EsportsFanWeb.Components.ExampleComponent

  def render(assigns) do
    ~F"""
    <ExampleComponent>
      Hi there!
    </ExampleComponent>
    """
  end
end
