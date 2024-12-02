defmodule SlaxWeb.DatesDatePickerLive do
  use SlaxWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-10 w-[400px] h-full">
      <%!-- <.dates_date_picker placeholder="Choose date" helpertext="aaaa" name="date" value="22" /> --%>
      <.live_component
        module={SlaxWeb.DatesDatePickerLiveComponent}
        placeholder="Choose date"
        helpertext="aaaa"
        name="date"
        value="22"
        label="aaaa"
        id="iii"
      />
    </div>
    """
  end
end
