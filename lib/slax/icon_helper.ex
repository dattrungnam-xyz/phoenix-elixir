# defmodule Slax.IconHelper do
#   @moduledoc """
#   Provides helper functions to render SVG icons in templates.
#   """

#   import Phoenix.HTML
#   alias SlaxWeb.Router.Helpers, as: Routes

#   def test do
#     # IO.puts SlaxWeb.static_paths()
#     # IO.puts SlaxWeb.Endpoint
#     # IO.puts()
#     svg_tag = """
#     <svg >
#       <use href="#{Routes.static_path(SlaxWeb.Endpoint, "/icons/bed.svg")}"></use>
#     </svg>
#     """

#     raw(svg_tag)
#   end

#   # def icon_tag(name, opts \\ []) do

#   #   id = Keyword.get(opts, :id, "")
#   #   classes = Keyword.get(opts, :class, "")

#   #   svg_tag = """
#   #   <svg id="#{id}" class="#{classes}">
#   #     <use href="#{Routes.static_path(SlaxWeb.Endpoint, "/icons/#{name}.svg")}"></use>
#   #   </svg>
#   #   """
#   #   raw(svg_tag)
#   # end
# end
