defmodule Chatbot.Chat do
  alias Chatbot.Chat.Message

  def new_user_message(%{role: :user} = attrs) do
    Message.changeset(attrs) |> Chatbot.Repo.insert!()
  end

  @llm LangChain.ChatModels.ChatOpenAI.new!(%{
         model: "gpt-4o-mini"
       })

  @chain LangChain.Chains.LLMChain.new!(%{llm: @llm})
         |> LangChain.Chains.LLMChain.add_message(
           LangChain.Message.new_system!("You give fun responses.")
         )

  def new_assistant_message(messages) do
    messages =
      Enum.map(messages, fn %{role: role, content: content} ->
        case role do
          :user -> LangChain.Message.new_user!(content)
          :assistant -> LangChain.Message.new_assistant!(content)
        end
      end)

    {:ok, _chain, response} =
      LangChain.Chains.LLMChain.add_messages(@chain, messages) |> LangChain.Chains.LLMChain.run()

    Message.changeset(%{role: :assistant, content: response.content}) |> Chatbot.Repo.insert!()
  end

  def all_messages() do
    Chatbot.Repo.all(Message)
  end
end
