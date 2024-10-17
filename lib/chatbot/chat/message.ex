defmodule Chatbot.Chat.Message do
  use Ecto.Schema

  @message_types [:user, :assistant, :system]

  schema "messages" do
    field :role, Ecto.Enum, values: @message_types
    field :content, :string

    timestamps()
  end

  def changeset(message \\ %__MODULE__{}, attrs) do
    Ecto.Changeset.cast(message, attrs, [:role, :content])
  end
end
