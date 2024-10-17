defmodule Chatbot.Chat do
  alias Chatbot.Chat.Message

  def new_message(attrs) do
    Message.changeset(attrs) |> Chatbot.Repo.insert!()
  end

  def all_messages() do
    Chatbot.Repo.all(Message)
  end
end
