defmodule Elide.V1.ElinkApiView do
  use Elide.Web, :view

  def render("show.json", %{elink: elink}) do
    render_one(elink, Elide.V1.ElinkApiView, "elink.json")
  end

  def render("elink.json", %{elink_api: elink}) do
    %{short_url: elink.short_url, id: elink.id}
  end

  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end
end
