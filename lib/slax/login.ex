defmodule Slax.Login do
  alias Slax.Repo
  alias Slax.Accounts.User
  alias Slax.Chat.{Message, Room, RoomMembership}
  import Ecto.Query
  import Ecto.Changeset


  def change_room(email, attrs \\ %{}) do
    User.validate_email(email, attrs)
  end

end
