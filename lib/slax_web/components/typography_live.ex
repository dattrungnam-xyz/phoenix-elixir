defmodule SlaxWeb.TypographyLive do
  use SlaxWeb, :live_component

  # def mount(socket) do
  #   variant = Map.get(params, "variant")
  #   class = Map.get(params, "class", "")

  #   new_class = get_variant_class(variant) <> " " <> class
  #   IO.inspect(new_class)
  #   IO.puts(11)
  #   {:ok, assign(socket, :new_class, new_class)}
  # end

  def update(assigns, socket) do
    variant = assigns[:variant]
    class = assigns[:class] || ""
    new_class = get_variant_class(variant) <> " " <> class
    {:ok, assign(socket, :new_class, new_class) |> assign(:inner_block, assigns[:inner_block])}
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

  def render(assigns) do
    ~H"""
    <div class={@new_class}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
