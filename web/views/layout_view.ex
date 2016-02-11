defmodule Elide.LayoutView do
  use Elide.Web, :view

  def allow_sing_up? do
    config = Application.get_env(:elide, Elide.Auth)
    config[:allow_sing_up]
  end
end
