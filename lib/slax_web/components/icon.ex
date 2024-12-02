# defmodule SlaxWeb.Icon do
#   use SlaxWeb, :live_component

#   attr :name, :string, required: true
#   attr :class, :string, default: ""
#   attr :id, :string, required: true
#   attr :style, :string, default: ""

#   def render(assigns) do
#     ~H"""
#     <img src={"/icons/#{@name}.svg"} class={@class} id={@id} style={@style} alt={@name} />
#     """
#   end
# end
