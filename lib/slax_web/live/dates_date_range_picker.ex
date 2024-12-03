defmodule SlaxWeb.DatesDateRangePickerLive do
  use SlaxWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-10 w-[320px] h-full">
      <%!-- <.dates_date_picker placeholder="Choose date" helpertext="aaaa" name="date" value="22" /> --%>
      <.live_component
        module={SlaxWeb.DatesDateRangePickerLiveComponent}
        placeholder="Choose date"
        helpertext="aaaa"
        id="iii"


      />
    </div>
    """
  end
end
