defmodule SlaxWeb.DatesDatePicker do
  use Phoenix.Component
  import SlaxWeb.Typography
  import SlaxWeb.CoreComponents

  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any
  attr :class, :string, default: ""
  attr :clearable, :boolean, default: false

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :required, :boolean, default: false
  attr :errors, :list, default: []
  attr :rest, :global, include: ~w(placeholder helpertext locale format disabled clearable)

  def dates_date_picker(assigns) do
    current_date = Date.utc_today()
    month = current_date.month

    ~H"""
    <div class={"w-full flex flex-col " <> @class}>
      <div class=" w-full relative">
        <.input
          name={@name}
          label={@label}
          value={@value}
          clearable={@clearable}
          errors={@errors}
          disabled={Map.get(assigns[:rest], :disabled)}
          placeholder={Map.get(assigns[:rest], :placeholder)}
        >
          <:icon>
            <.icon name="date" class="w-4 h-4" />
          </:icon>
        </.input>

        <div class="absolute w-full top-full left-0 bg-white p-3.5 h-auto z-10 border border-neutral-200 rounded-lg overflow-hidden shadow-md ">
          <div class="flex items-center justify-between">
            <div class="pointer p-[10px] flex">
              <.icon name="chevron-left" class="w-[14px] h-[14px]" />
            </div>
            <.typography variant="b1-highlight" class="text-[#4B5563] select-none leading-none">
              current year
            </.typography>
            <div class="pointer p-[10px] flex">
              <.icon name="chevron-right" class="w-[14px] h-[14px]" />
            </div>
          </div>
          <div class="flex overflow-hidden rounded justify-between"></div>
        </div>
      </div>
      <.typography :if={Map.get(assigns[:rest], :helpertext)} variant="c1" class="secondary-text">
        <%= Map.get(assigns[:rest], :helpertext) %>
      </.typography>
    </div>
    """
  end
end
