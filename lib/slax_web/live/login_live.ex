defmodule SlaxWeb.LoginLive do
  alias Slax.Login
  alias Slax.Accounts
  use SlaxWeb, :live_view
  import SlaxWeb.Typography
  alias Slax.Accounts.User
  alias Ecto.Changeset

  def mount(_params, _session, socket) do
    # email = Phoenix.Flash.get(socket.assigns.flash, :email)
    # form = to_form(%{"email" => email}, as: "user")
    # {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
    email = Phoenix.Flash.get(socket.assigns.flash, :email)

    if(socket.assigns.live_action == :code && !email) do
      {:ok,
       socket
       |> redirect(to: "/login")}
    else
      form = to_form(%{"email" => email}, as: "email")
      code_form = to_form(%{"code" => nil}, as: "code")
      # {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
      {:ok, assign(socket, code_form: code_form, form: form, email: email),
       temporary_assigns: [code_form: code_form, form: form]}
    end
  end

  def handle_event("login_email", params, socket) do
    # changeset = Map.put(Accounts.change_email(%User{}, email), :action, :validate)
    # IO.inspect(to_form(changeset, as: "email"))
    %{"email" => email} = params
    changeset = Accounts.change_email(%User{}, email)

    if changeset.valid? do
      {:noreply, socket |> put_flash(:email, email) |> redirect(to: "/login/code")}
    else
      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  def maskingEmail(params) do
    email = Map.get(params, "email")
    [local_part, domain] = String.split(email, "@")
    String.slice(email, 0..4) <> "****" <> "@" <> domain
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "email")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-1 w-full flex-col">
      <div class="flex pt-[10px] justify-center items-center">
        <img src={~p"/images/logo.svg"} />
      </div>
      <div class="flex flex-1 justify-center pt-[200px] px-[80px]">
        <div>
          <div class="flex flex-1 w-[360px] max-w-[360px] h-fit gap-[25px] flex-col rounded-xl bg-[white] items-center">
            <div :if={@live_action == nil} class="flex flex-col gap-2 items-center justify-center">
              <.live_component module={SlaxWeb.TypographyLive} variant="h3" id="iii">
                Log in to Gastrosmart
              </.live_component>
              <.typography
                variant="b1"
                class="flex flex-wrap gap-1 text-neutral-600 font-normal items-center justify-center"
              >
                Welcome! Please enter your detail.
              </.typography>
            </div>
            <div :if={@live_action == :code} class="flex flex-col gap-2 items-center justify-center">
              <.live_component module={SlaxWeb.TypographyLive} variant="h3" id="iii">
                Verification by Email
              </.live_component>
              <.typography
                variant="b1"
                class="flex flex-wrap gap-1 text-neutral-600 font-normal items-center justify-center text-center"
              >
                We’ve just sent you a code to email ending in <%= maskingEmail(@email) %>. Please enter this code below.
              </.typography>
            </div>
            <%!-- <.simple_form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate_email"
              action={~p"/users/log_in?_action=registered"}
              method="post"
            >
              <.input field={@form[:email]} type="email" label="Email" required />

              <:actions>
                <.button phx-disable-with="Creating account..." class="w-full">
                  Create an account
                </.button>
              </:actions>
            </.simple_form> --%>
            <.simple_form
              :if={@live_action == nil}
              for={@form}
              id="login_form"
              action={~p"/users/log_in"}
              phx-submit="login_email"
              method="post"
            >
              <.input field={@form[:email]} type="text" label="Email" required></.input>
              <:actions>
                <div class="flex w-full flex-col gap-[22px] items-center justify-center">
                  <.button>
                    Continue
                  </.button>
                </div>
              </:actions>
            </.simple_form>
            <.simple_form
              :if={@live_action == :code}
              for={@code_form}
              id="code_form"
              action={~p"/users/log_in"}
              phx-update="ignore"
            >
              <.input field={@code_form[:code]} type="text" label="Enter Code"></.input>
              <:actions>
                <div class="flex w-full flex-col gap-[22px] items-center justify-center">
                  <.button>
                    Continue
                  </.button>
                </div>
              </:actions>
            </.simple_form>
          </div>
        </div>
      </div>
      <.footer />
    </div>
    <div class="flex flex-col gap-10 max-w-[700px] p-[60px_0_40px_60px] h-full flex-shrink-0 rounded-lg filter-blur-0">
      <img class="w-full h-full" src={~p"/images/background.png"} />
    </div>
    """
  end

  def footer(assigns) do
    ~H"""
    <div class=" flex items-center justify-center mb-8 w-full gap-[10px] relative">
      <.typography class="text-neutral-500" variant="b1">
        © GastroSmart
      </.typography>
      <div class="block w-[4px] h-[4px] bg-neutral-500 rounded-full"></div>
      <.typography class="text-neutral-500" variant="b1">
        Die Software für Großküchen
      </.typography>
      <div class="block w-[4px] h-[4px] bg-neutral-500 rounded-full"></div>
      <gs3-d-buttons-button_link href="" class=" text-neutral-500 underline">
        <.typography class="text-darkblue-500" variant="b1">
          Privacy Policy
        </.typography>
      </gs3-d-buttons-button_link>
      <div class="block w-[4px] h-[4px] bg-neutral-500 rounded-full"></div>
      <gs3-d-buttons-button_link href="" class=" text-neutral-500 underline">
        <.typography class="text-darkblue-500" variant="b1">
          Terms of Conditions
        </.typography>
      </gs3-d-buttons-button_link>
    </div>
    """
  end
end
