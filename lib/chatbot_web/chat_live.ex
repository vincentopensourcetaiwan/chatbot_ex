defmodule ChatbotWeb.ChatLive do
  use ChatbotWeb, :live_view
  alias Chatbot.Chat
  import ChatbotWeb.CoreComponents

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:messages, Chat.all_messages())
      |> assign(:form, to_form(%{"message" => ""}))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= for message <- @messages do %>
      <.chat_message role={message.role} content={message.content} />
    <% end %>

    <.simple_form for={@form} phx-submit="send">
      <.input field={@form[:message]} label="Message" />
      <:actions>
        <.button>Send</.button>
      </:actions>
    </.simple_form>
    """
  end

  defp chat_message(assigns) do
    ~H"""
    <p><%= @role %>: <%= @content %></p>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("send", %{"message" => message}, socket) do
    messages = socket.assigns.messages
    user_message = Chat.create_user_message(%{role: :user, content: message})

    messages = messages ++ [user_message]

    Chat.stream_assistant_message(messages, self())

    messages = messages ++ [%{role: :assistant, content: ""}]

    {:noreply, assign(socket, :messages, messages)}
  end

  @impl Phoenix.LiveView
  def handle_info({:new_assistant_message, messages}, socket) do
    {:ok, assistant_message} = Chat.create_assistant_message(messages)

    messages = messages ++ [assistant_message]
    {:noreply, assign(socket, :messages, messages)}
  end

  def handle_info({:next_message_delta, nil}, socket) do
    {:noreply, socket}
  end

  def handle_info({:next_message_delta, message_delta}, socket) do
    [latest_assistant_message | messages] = Enum.reverse(socket.assigns.messages)

    latest_assistant_message = %{
      latest_assistant_message
      | content: latest_assistant_message.content <> message_delta
    }

    messages = [latest_assistant_message | messages] |> Enum.reverse()

    {:noreply, assign(socket, :messages, messages)}
  end

  def handle_info({:message_processed, completed_message}, socket) do
    [latest_assistant_message | messages] = Enum.reverse(socket.assigns.messages)

    latest_assistant_message = %{
      latest_assistant_message
      | content: completed_message
    }

    messages = [latest_assistant_message | messages] |> Enum.reverse()

    {:noreply, assign(socket, :messages, messages)}
  end
end
