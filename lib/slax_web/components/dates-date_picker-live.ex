defmodule SlaxWeb.DatesDatePickerLiveComponent do
  use Phoenix.LiveComponent
  import SlaxWeb.Typography
  import SlaxWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div class={"w-full flex flex-col " <> @class}>
      <div class="w-full relative">
        <.input
          name={@name}
          label={@label}
          value={@select_date}
          clearable={@clearable}
          errors={@errors}
          disabled={@disabled}
          placeholder={@placeholder}
        >
          <:icon>
            <.icon name="date" class="w-4 h-4" />
          </:icon>
        </.input>

        <div class="absolute w-full top-full left-0 bg-white p-3.5 h-auto z-10 border border-neutral-200 rounded-lg overflow-hidden shadow-md ">
          <div class="flex items-center justify-between">
            <div
              class="pointer p-[10px] flex"
              phx-target={@myself}
              phx-click="navigate_month"
              phx-value-direction="prev"
            >
              <.icon name="chevron-left" class="w-[14px] h-[14px]" />
            </div>
            <.typography variant="b1-highlight" class="text-[#4B5563] select-none leading-none">
              <%= month_to_string(@display_date.month) %> <%= @display_date.year %>
            </.typography>
            <div
              class="pointer p-[10px] flex"
              phx-target={@myself}
              phx-click="navigate_month"
              phx-value-direction="next"
            >
              <.icon name="chevron-right" class="w-[14px] h-[14px]" />
            </div>
          </div>
          <div class="flex overflow-hidden rounded justify-between">
            <div class="weeks">
              <div class="week grid w-10 grid-cols-1 text-[#9CA3AF] bg-[#F9FAFB] border-r border-[#D1D5DB] h-[36px] min-h-[36px]">
                <.typography
                  variant="c1"
                  class="text-[#9CA3AF] py-[10px] items-center text-center justify-center block select-none"
                >
                  week
                </.typography>
              </div>
              <div class="week grid w-10 grid-cols-1 text-[#9CA3AF] bg-[#F9FAFB] border-r border-[#D1D5DB]">
                <%= for week <- get_weeks_in_month(@display_date) do %>
                  <%= if week == "" do %>
                    <div class="empty h-[36px] min-h-[36px]"></div>
                  <% else %>
                    <.typography
                      variant="c1"
                      class="week-number p-[10px] items-center justify-center block select-none h-[36px] min-h-[36px]"
                    >
                      <%= week %>
                    </.typography>
                  <% end %>
                <% end %>
              </div>
            </div>
            <div class="flex-1">
              <div class="dayNames grid grid-cols-7 text-[#9CA3AF] bg-[#F9FAFB]">
                <%= for name <- @day_names do %>
                  <.typography
                    variant="c1"
                    class="h-[36px] min-h-[36px] text-center py-[10px] block select-none leading-4"
                  >
                    <%= name %>
                  </.typography>
                <% end %>
              </div>
              <div class="days grid grid-cols-7">
                <%= for day <- get_date_in_month(@display_date) do %>
                  <%= if day == -1 do %>
                    <div class="empty pointer-events-none h-[36px] min-h-[36px] w-[32.6px] pointer color-[#374151] flex items-center justify-center rounded">
                    </div>
                  <% else %>
                    <div
                      class={"day items-center justify-center block h-[36px] min-h-[36px] w-full pointer color-[#374151] flex items-center justify-center rounded hover:bg-[#33789A] hover:text-[white] " <> if Date.compare(Date.new!(@display_date.year, @display_date.month, day), @select_date) == :eq, do: "bg-[#005681] text-white", else: ""}
                      style="cursor:pointer"
                      phx-target={@myself}
                      phx-click="select_date"
                      phx-value-day={day}
                    >
                      <.typography variant="b1" class="pointer">
                        <%= day %>
                      </.typography>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
      <.typography :if={@helpertext} variant="c1" class="secondary-text">
        <%= @helpertext %>
      </.typography>
    </div>
    """
  end

  @impl true
  def handle_event("navigate_month", %{"direction" => direction}, socket) do
    current_display_date = socket.assigns.display_date

    socket =
      if direction == "prev" do
        new_display_month =
          if current_display_date.month != 1 do
            current_display_date.month - 1
          else
            12
          end

        new_display_year =
          if current_display_date.month != 1 do
            current_display_date.year
          else
            current_display_date.year - 1
          end

        new_display_date = Date.new!(new_display_year, new_display_month, 1)

        socket
        |> assign(:display_date, new_display_date)
      else
        new_display_month =
          if current_display_date.month != 12 do
            current_display_date.month + 1
          else
            1
          end

        new_display_year =
          if current_display_date.month != 12 do
            current_display_date.year
          else
            current_display_date.year + 1
          end

        new_display_date = Date.new!(new_display_year, new_display_month, 1)

        socket
        |> assign(:display_date, new_display_date)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_date", %{"day" => day}, socket) do
    current_display_date = socket.assigns.display_date

    day = String.to_integer(day)
    {:ok, new_select_date} = Date.new(current_display_date.year, current_display_date.month, day)

    socket =
      socket
      |> assign(:select_date, new_select_date)

    {:noreply, socket}
  end

  @impl true
  def update(assigns, socket) do
    # {:ok, date} = Date.new(2024, 1, 1)
    socket =
      socket
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:name, fn -> nil end)
      |> assign_new(:label, fn -> nil end)
      |> assign_new(:clearable, fn -> false end)
      |> assign_new(:errors, fn -> [] end)
      |> assign_new(:helpertext, fn -> nil end)
      |> assign_new(:disabled, fn -> false end)
      |> assign_new(:placeholder, fn -> nil end)
      |> assign(:select_date, Date.utc_today())
      |> assign(:display_date, Date.utc_today())
      |> assign(:day_names, ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])

    {:ok, socket}
  end

  defp month_to_string(month) do
    case month do
      1 -> "January"
      2 -> "February"
      3 -> "March"
      4 -> "April"
      5 -> "May"
      6 -> "June"
      7 -> "July"
      8 -> "August"
      9 -> "September"
      10 -> "October"
      11 -> "November"
      12 -> "December"
    end
  end

  def get_weeks_in_month(date) do
    year = date.year
    month = date.month

    {:ok, first_day} = Date.new(year, month, 1)
    last_day = Date.end_of_month(date)
    {:ok, current_day} = Date.new(year, month, 1)
    day_of_week = Date.day_of_week(current_day)

    current_day_adjusted =
      if day_of_week != 1 do
        Date.add(current_day, 8 - day_of_week)
      else
        current_day
      end

    list_week = []
    week_number = get_week_of_year(first_day)
    list_week = list_week ++ [week_number]

    list_week =
      Enum.reduce_while(get_week_of_year(first_day)..get_week_of_year(last_day), list_week, fn i,
                                                                                               acc ->
        if i not in acc do
          {:cont, acc ++ [i]}
        else
          {:cont, acc}
        end
      end)

    list_week
  end

  def get_week_of_year(date) do
    {:ok, first_day_of_year} = Date.new(date.year, 1, 1)

    day_of_week = Date.day_of_week(first_day_of_year)

    current_day_adjusted =
      if day_of_week != 1 do
        Date.add(first_day_of_year, 8 - day_of_week)
      else
        first_day_of_year
      end

    if Date.compare(date, current_day_adjusted) == :lt do
      1
    else
      days_diff = Date.diff(date, current_day_adjusted)

      week_number = div(days_diff, 7) + 2

      week_number
    end
  end

  def get_date_in_month(date) do
    year = date.year
    month = date.month

    {:ok, first_day} = Date.new(year, month, 1)

    day_of_week = Date.day_of_week(first_day)

    date_list =
      if day_of_week != 1 do
        Enum.reduce(1..(day_of_week - 1), [], fn _, acc ->
          acc ++ [-1]
        end)
      else
        []
      end

    date_list =
      Enum.reduce(1..Date.days_in_month(date), date_list, fn day, acc ->
        acc ++ [day]
      end)

    date_list
  end
end
