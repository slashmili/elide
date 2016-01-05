defmodule Elide.PageController do
  use Elide.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
