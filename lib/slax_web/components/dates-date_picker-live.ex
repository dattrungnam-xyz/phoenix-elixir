defmodule SlaxWeb.DatesDatePickerLiveComponent do
  use Phoenix.LiveComponent
  import SlaxWeb.Typography
  import SlaxWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="DatePicker" id="date-picker" class={"w-full flex flex-col " <> @class}>
      <div class="w-full relative">
        <%!-- clearable={@clearable} --%>

        <.input
          name={@name}
          label={@label}
          value={convert_to_date_format(@select_date, @format)}
          errors={@errors}
          disabled={@disabled}
          placeholder={@placeholder}
          phx-target={@myself}
          phx-keyup="input-date"
          phx-blur="check-date"
          id="input"
        >
          <:icon>
            <.icon name="date" class="w-4 h-4" />
          </:icon>
        </.input>

        <div class={"absolute w-full top-full left-0 bg-white p-3.5 h-auto z-10 border border-neutral-200 rounded-lg overflow-hidden shadow-md " <> if @show_picker, do: "block", else: "hidden"}>
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
  def handle_event("input-date", params, socket) do
    format = socket.assigns.format

    socket =
      if validDate?(params["value"], format) do
        select_date = get_date_from_input(params["value"], format)
        {:ok, display_date} = Date.new(select_date.year, select_date.month, 1)
        assign(socket, :select_date, select_date) |> assign(:display_date, display_date)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("check-date", params, socket) do
    format = socket.assigns.format

    socket =
      if validDate?(params["value"], format) do
        select_date = get_date_from_input(params["value"], format)
        {:ok, display_date} = Date.new(select_date.year, select_date.month, 1)
        assign(socket, :select_date, select_date) |> assign(:display_date, display_date)
      else
        socket
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
  def handle_event("open_datepicker", _params, socket) do
    socket =
      if socket.assigns.disabled do
        socket
      else
        assign(socket, :show_picker, true)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_datepicker", _params, socket) do
    socket = assign(socket, :show_picker, false)
    {:noreply, socket}
  end

  @impl true
  def update(assigns, socket) do
    # {:ok, date} = Date.new(2024, 1, 1)
    socket =
      socket
      |> assign_new(:class, fn -> Map.get(assigns, :class, "") end)
      |> assign_new(:name, fn -> Map.get(assigns, :name, nil) end)
      |> assign_new(:label, fn -> Map.get(assigns, :label, nil) end)
      |> assign_new(:clearable, fn -> Map.get(assigns, :clearable, false) end)
      |> assign_new(:errors, fn -> Map.get(assigns, :errors, []) end)
      |> assign_new(:helpertext, fn -> Map.get(assigns, :helpertext, nil) end)
      |> assign_new(:disabled, fn -> Map.get(assigns, :disabled, false) end)
      |> assign_new(:placeholder, fn -> Map.get(assigns, :placeholder, nil) end)
      |> assign_new(:format, fn -> Map.get(assigns, :format, "mm/dd/yyyy") end)
      |> assign_new(:select_date, fn -> Map.get(assigns, :select_date, Date.utc_today()) end)
      |> assign_new(:display_date, fn -> Map.get(assigns, :display_date, Date.utc_today()) end)
      |> assign_new(:day_names, fn ->
        Map.get(assigns, :day_names, ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
      end)
      |> assign_new(:show_picker, fn -> Map.get(assigns, :show_picker, false) end)

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
    # {:ok, current_day} = Date.new(year, month, 1)
    # day_of_week = Date.day_of_week(current_day)

    # current_day_adjusted =
    #   if day_of_week != 1 do
    #     Date.add(current_day, 8 - day_of_week)
    #   else
    #     current_day
    #   end

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

  def convert_to_date_format(date, format) do
    mm = date.month
    dd = date.day
    yyyy = date.year

    case format do
      "mm/dd/yyyy" -> "#{pad(mm)}.#{pad(dd)}.#{yyyy}"
      "dd/mm/yyyy" -> "#{pad(dd)}.#{pad(mm)}.#{yyyy}"
      _ -> "#{pad(mm)}.#{pad(dd)}.#{yyyy}"
    end
  end

  defp pad(value) when value < 10 do
    "0#{value}"
  end

  defp pad(value) do
    "#{value}"
  end

  def validDate?(dateStr, format) do
    date_parts = String.split(dateStr, ".")
    parts = String.split(format, "/")
    date_map = Enum.zip(parts, date_parts) |> Enum.into(%{})

    with {:ok, day} <- Map.fetch(date_map, "dd"),
         {:ok, month} <- Map.fetch(date_map, "mm"),
         {:ok, year} <- Map.fetch(date_map, "yyyy"),
         true <- year != "",
         true <- String.match?(day, ~r/^\d+$/),
         true <- String.match?(month, ~r/^\d+$/),
         true <- String.match?(year, ~r/^\d+$/),
         {:ok, _date} <-
           Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day)) do
      true
    else
      _ -> false
    end
  end

  def get_date_from_input(dateStr, format) do
    date_parts = String.split(dateStr, ".")
    parts = String.split(format, "/")
    date_map = Enum.zip(parts, date_parts) |> Enum.into(%{})

    {:ok, day} = Map.fetch(date_map, "dd")
    {:ok, month} = Map.fetch(date_map, "mm")
    {:ok, year} = Map.fetch(date_map, "yyyy")

    {:ok, date} =
      Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))

    date
  end
end
