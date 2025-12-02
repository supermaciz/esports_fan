defmodule EsportsFanWeb.PageController do
  use EsportsFanWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
