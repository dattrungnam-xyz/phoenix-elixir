defmodule SlaxWeb.DatesDateRangePickerLiveComponent do
  use Phoenix.LiveComponent
  import SlaxWeb.Typography
  import SlaxWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="DatePicker" id="date-picker" class="container w-[320px] text-[#374151] rounded-md ">
      <div class="container-date-range-picker relative">
        <div name="label">
          <div class={
            if @single_input,
              do:
                "input-container flex flex-row items-center border w-full border border-[#E5E7E8] hover:border-[#005681] rounded shadow-custom",
              else: "input-container flex flex-row gap-2 w-full"
          }>
            <.input
              class=""
              name={@start_name}
              label={if @single_input, do: "", else: @start_label}
              placeholder=""
              required={@required}
              value={convert_to_date_format(@start_date, @format)}
              type={if @single_input, do: "double", else: "text"}
              phx-keyup="input-date"
              phx-target={@myself}
              id="start-date"
              phx-value-name="start-date"
            >
              <:icon>
                <.icon class="icon-calendar  w-4 h-4" name="date" />
              </:icon>
            </.input>
            <span :if={@single_input}>-</span>
            <.input
              name={@end_name}
              label={if @single_input, do: "", else: @end_label}
              placeholder=""
              required={@required}
              value={convert_to_date_format(@end_date, @format)}
              type={if @single_input, do: "double", else: "text"}
              phx-keyup="input-date"
              id="end-date"
              phx-value-name="end-date"
              phx-target={@myself}
            >
              <:icon :if={!@single_input}>
                <.icon class="icon-calendar  w-4 h-4" name="date" />
              </:icon>
            </.input>
          </div>
        </div>
        <div class={if @show_picker, do: "block", else: "hidden"}>
          <div class="calendar calendar-months absolute top-full left-0 z-10 bg-[white] px-4 py-3 h-auto border border-[#E5E7EB] round-md overflow-hidden select-none shadow-boxShadow gap-3 flex w-auto">
            <%= for date <- [@display_date, @middle_display_date, @last_display_date] do %>
              <%= render_month_week(assigns, date) %>
            <% end %>
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
  def update(assigns, socket) do
    # {:ok, date} = Date.new(2024, 1, 1)

    display_date = Map.get(assigns, :display_date, Date.utc_today())

    middle_display_date =
      display_date
      |> Date.add(Date.days_in_month(display_date))
      |> Date.beginning_of_month()

    last_display_date =
      middle_display_date
      |> Date.add(Date.days_in_month(middle_display_date))
      |> Date.beginning_of_month()

    socket =
      socket
      |> assign_new(:class, fn -> Map.get(assigns, :class, "") end)
      |> assign_new(:start_name, fn -> Map.get(assigns, :start_name, nil) end)
      |> assign_new(:end_name, fn -> Map.get(assigns, :end_name, nil) end)
      |> assign_new(:start_label, fn -> Map.get(assigns, :start_label, nil) end)
      |> assign_new(:end_label, fn -> Map.get(assigns, :end_label, nil) end)
      |> assign_new(:label, fn -> Map.get(assigns, :label, nil) end)
      |> assign_new(:clearable, fn -> Map.get(assigns, :clearable, false) end)
      |> assign_new(:errors, fn -> Map.get(assigns, :errors, []) end)
      |> assign_new(:helpertext, fn -> Map.get(assigns, :helpertext, nil) end)
      |> assign_new(:disabled, fn -> Map.get(assigns, :disabled, false) end)
      |> assign_new(:single_input, fn -> Map.get(assigns, :single_input, false) end)
      |> assign_new(:required, fn -> Map.get(assigns, :required, false) end)
      |> assign_new(:placeholder, fn -> Map.get(assigns, :placeholder, nil) end)
      |> assign_new(:format, fn -> Map.get(assigns, :format, "mm/dd/yyyy") end)
      |> assign_new(:start_date, fn -> Map.get(assigns, :start_date, nil) end)
      |> assign_new(:end_date, fn -> Map.get(assigns, :end_date, nil) end)
      |> assign_new(:display_date, fn -> display_date end)
      |> assign_new(:day_names, fn ->
        Map.get(assigns, :day_names, ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
      end)
      |> assign_new(:show_picker, fn -> Map.get(assigns, :show_picker, false) end)
      |> assign(:middle_display_date, middle_display_date)
      |> assign(:today, Date.utc_today())
      |> assign(:last_display_date, last_display_date)
      |> assign(:pre_set, "end")

    # |> assign(:start_date, middle_display_date)
    # |> assign(:end_date, last_display_date)

    {:ok, socket}
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
        |> handle_update_month(new_display_date)
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
        |> handle_update_month(new_display_date)
        |> assign(:display_date, new_display_date)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_date", params, socket) do
    day = Map.get(params, "day")
    month = Map.get(params, "month")
    year = Map.get(params, "year")

    selected_date =
      Date.new!(String.to_integer(year), String.to_integer(month), String.to_integer(day))

    socket =
      cond do
        socket.assigns.start_date == nil ->
          assign(socket, :start_date, selected_date) |> assign(:pre_set, "start")

        socket.assigns.end_date == nil ->
          assign(socket, :end_date, selected_date) |> assign(:pre_set, "end")

        true ->
          pre_set = socket.assigns.pre_set

          if pre_set == "start" do
            assign(socket, :end_date, selected_date) |> assign(:pre_set, "end")
          else
            assign(socket, :start_date, selected_date) |> assign(:pre_set, "start")
          end
      end

    start_date = socket.assigns.start_date
    end_date = socket.assigns.end_date
    IO.inspect(start_date)
    IO.inspect(end_date)

    socket =
      if start_date != nil && end_date != nil && Date.compare(start_date, end_date) == :gt do
        assign(socket, :start_date, end_date)
        |> assign(:end_date, start_date)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("open_datepicker", _params, socket) do
    IO.puts("show picker")

    socket =
      if socket.assigns.disabled do
        IO.inspect("a")
        socket
      else
        IO.inspect("b")
        assign(socket, :show_picker, true)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_datepicker", _params, socket) do
    IO.puts("close_datepicker")
    socket = assign(socket, :show_picker, false)
    {:noreply, socket}
  end

  @impl true
  def handle_event("input-date", params, socket) do
    format = socket.assigns.format
    IO.inspect(params)

    socket =
      if validDate?(params["value"], format) do
        input_date = get_date_from_input(params["value"], format)

        cond do
          params["name"] == "start-date" and socket.assigns.end_date == nil ->
            IO.inspect(input_date)

            assign(socket, :start_date, input_date)
            |> assign(:display_date, input_date)
            |> handle_update_month(input_date)
            |> assign(:pre_set, "start")

          params["name"] == "start-date" and
              Date.compare(input_date, socket.assigns.end_date) != :gt ->
            IO.inspect(input_date)

            assign(socket, :start_date, input_date)
            |> assign(:display_date, input_date)
            |> handle_update_month(input_date)
            |> assign(:pre_set, "start")

          params["name"] == "end-date" and socket.assigns.start_date == nil ->
            new_display_date = first_day_of_previous_two_months(input_date)

            assign(socket, :end_date, input_date)
            |> assign(:display_date, new_display_date)
            |> handle_update_month(new_display_date)
            |> assign(:pre_set, "end")

          params["name"] == "end-date" and
              Date.compare(socket.assigns.start_date, input_date) != :gt ->
            new_display_date = first_day_of_previous_two_months(input_date)

            assign(socket, :end_date, input_date)
            |> assign(:display_date, new_display_date)
            |> handle_update_month(new_display_date)
            |> assign(:pre_set, "end")

          true ->
            socket
        end
      else
        socket
      end

    IO.inspect(socket.assigns.display_date)

    # {:ok, display_date} = Date.new(select_date.year, select_date.month, 1)
    # assign(socket, :select_date, select_date) |> assign(:display_date, display_date)

    {:noreply, socket}
  end

  def first_day_of_previous_two_months(date) do
    {year, month, _day} = Date.to_erl(date)

    {previous_month, previous_year} =
      if month <= 2 do
        {12 + (month - 2), year - 1}
      else
        {month - 2, year}
      end

    {:ok, new_date} = Date.new(previous_year, previous_month, 1)
    new_date
  end

  def handle_update_month(socket, display_date) do
    middle_display_date =
      display_date
      |> Date.add(Date.days_in_month(display_date))
      |> Date.beginning_of_month()

    last_display_date =
      middle_display_date
      |> Date.add(Date.days_in_month(middle_display_date))
      |> Date.beginning_of_month()

    socket
    |> assign(:middle_display_date, middle_display_date)
    |> assign(:last_display_date, last_display_date)
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

  def convert_to_date_format(nil, _format), do: ""

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

  defp render_month_week(assigns, date) do
    ~H"""
    <div class="min-w-[300px]">
      <div class="top-bar flex items-center justify-between min-h-[34px]">
        <div
          phx-target={@myself}
          phx-click="navigate_month"
          phx-value-direction="prev"
          class="buttons flex items-center"
        >
          <div class="change-button flex p-[10px] pointer">
            <.icon name="chevron-left" class="w-[14px] h-[14px]" />
          </div>
        </div>
        <.typography
          variant="b1-highlight"
          class="monthYear text-[#4B5563] p-1 flex-1 text-center leading-1"
        >
          <%= month_to_string(date.month) %> <%= date.year %>
        </.typography>
        <div
          phx-target={@myself}
          phx-click="navigate_month"
          phx-value-direction="next"
          class="buttons flex items-center"
        >
          <div class="change-button flex p-[10px] pointer">
            <.icon name="chevron-right" class="w-[14px] h-[14px]" />
          </div>
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
            <%= for week <- get_weeks_in_month(date) do %>
              <%= if week == "" do %>
                <div class="empty h-[36px] min-h-[36px]"></div>
              <% else %>
                <div class="flex items-center justify-center select-none h-[36px] min-h-[36px]">
                  <.typography
                    variant="c1"
                    class={"week-number flex w-6 h-6 items-center justify-center block select-none "
                  <> get_class_week_element(week, @start_date, @end_date)
                  }
                  >
                    <%= week %>
                  </.typography>
                </div>
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
            <%= for day <- get_date_in_month(date) do %>
              <%= if day == -1 do %>
                <div class="empty pointer-events-none h-[36px] min-h-[36px] w-[32.6px] pointer color-[#374151] flex items-center justify-center rounded">
                </div>
              <% else %>
                <div
                  class={
                    get_class_date_element(
                      Date.new!(date.year, date.month, day),
                      @start_date,
                      @end_date
                    )
                  }
                  style="cursor:pointer"
                  phx-target={@myself}
                  phx-click="select_date"
                  phx-value-day={day}
                  phx-value-month={date.month}
                  phx-value-year={date.year}
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
    """
  end

  def get_class_date_element(date, start_date, end_date) do
    today = Date.utc_today()

    cond do
      start_date != nil && Date.compare(date, start_date) == :eq ->
        "day items-center justify-center block h-[36px] min-h-[36px] w-full pointer color-[#374151] flex items-center justify-center rounded-l-md hover:bg-[#33789A] hover:text-[white] bg-[#005681] text-white"

      end_date != nil && Date.compare(date, end_date) == :eq ->
        "day items-center justify-center block h-[36px] min-h-[36px] w-full pointer color-[#374151] flex items-center justify-center rounded-r-md hover:bg-[#33789A] hover:text-[white] bg-[#005681] text-white"

      start_date != nil && end_date != nil &&
        Date.compare(date, start_date) == :gt && Date.compare(date, end_date) == :lt ->
        "day items-center justify-center block h-[36px] min-h-[36px] w-full pointer color-[#374151] flex items-center justify-center rounded hover:bg-[#33789A] hover:text-[white] bg-[#E6EEF2] rounded-none"

      Date.compare(date, today) == :eq ->
        "day items-center justify-center block h-[36px] min-h-[36px] w-full pointer color-[#374151] flex items-center justify-center rounded hover:bg-[#33789A] hover:text-[white] font-bold bg-[#FFEDD5] text-black"

      true ->
        "day items-center justify-center block h-[36px] min-h-[36px] w-full pointer color-[#374151] flex items-center justify-center rounded hover:bg-[#33789A] hover:text-[white] "
    end
  end

  def get_class_week_element(week, start_date, end_date) do
    if start_date == nil || end_date == nil do
      ""
    else
      week_start_date = get_week_of_year(start_date)
      week_end_date = get_week_of_year(end_date)

      cond do
        (week_start_date == week && Date.day_of_week(start_date) != 1) or
          (week_end_date == week && Date.day_of_week(end_date) != 7) or
          week_start_date > week or week_end_date < week ->
          ""

        true ->
          "bg-[#005681] text-white rounded-md"
      end
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
