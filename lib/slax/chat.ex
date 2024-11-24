defmodule Slax.Chat do
  alias Slax.Repo
  alias Slax.Accounts.User
  alias Slax.Chat.{Room, Message}
  import Ecto.Query

  def get_first_room! do
    Repo.one(from r in Room, limit: 1, order_by: [asc: :name])
  end

  def get_room!(id) do
    Repo.get!(Room, id)
  end

  def list_rooms do
    Room |> Repo.all()
  end

  def create_room(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def update_room(room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def change_room(room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def get_list_of_messages(room) do
    Repo.all(
      from m in Message,
        where: m.room_id == ^room.id,
        order_by: [asc: :inserted_at, desc: :id],
        preload: [:room, :user]
    )
  end

  def change_message(message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def create_message(attrs, user, room) do
    %Message{user: user, room: room} |> Message.changeset(attrs) |> Repo.insert()
  end

  def delete_message_by_id(id, %User{id: user_id}) do
    message = %Message{user_id: ^user_id} = Repo.get(Message, id)

    Repo.delete(message)
  end
end
