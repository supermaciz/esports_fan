defmodule EsportsFanWeb.Components.TitleComponent do
  use Surface.Component

  slot default, required: true

  def render(assigns) do
    ~F"""
    <h1 class="text-3xl sm:text-4xl font-semibold tracking-tight text-slate-900">
      <#slot/>
    </h1>
    """
  end
end
