defmodule SlaxWeb.Typography do
  use Phoenix.Component

  attr :variant, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block

  def typography(assigns) do
    class =
      get_variant_class(assigns[:variant]) <> " " <> assigns[:class]

    assigns = assign(assigns, :class, class)

    ~H"""
    <div class={@class}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp get_variant_class("h1"), do: "text-4xl font-medium leading-tight"
  defp get_variant_class("h2"), do: "text-3xl font-medium leading-snug"
  defp get_variant_class("h3"), do: "text-2xl font-semibold leading-tight"
  defp get_variant_class("h4"), do: "text-xl font-semibold leading-tight"
  defp get_variant_class("s1"), do: "text-base font-normal leading-relaxed"
  defp get_variant_class("s2"), do: "text-sm font-normal leading-relaxed"
  defp get_variant_class("b1"), do: "text-sm font-normal leading-relaxed"
  defp get_variant_class("b1-highlight"), do: "text-sm font-bold leading-relaxed"
  defp get_variant_class("c1"), do: "text-xs font-normal leading-snug"
  defp get_variant_class("c1-highlight"), do: "text-xs font-semibold leading-snug"
  defp get_variant_class(_), do: "text-base font-normal"
end
