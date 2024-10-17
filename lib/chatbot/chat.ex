defmodule Chatbot.Chat do
  alias Chatbot.Chat.Message

  def new_user_message(%{role: :user} = attrs) do
    Message.changeset(attrs) |> Chatbot.Repo.insert!()
  end

  def new_assistant_message(messages) do
    content = "blabla"

    Message.changeset(%{role: :assistant, content: content}) |> Chatbot.Repo.insert!()
  end

  def all_messages() do
    Chatbot.Repo.all(Message)
  end
end
