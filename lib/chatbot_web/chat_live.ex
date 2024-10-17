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
    <%= for m <- @messages do %>
      <p>role: <%= m.role %> content: <%= m.content %></p>
    <% end %>

    <.simple_form for={@form} phx-submit="send">
      <.input field={@form[:message]} label="Message" />
      <:actions>
        <.button>Send</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("send", %{"message" => message}, socket) do
    messages = socket.assigns.messages
    user_message = Chat.new_user_message(%{role: :user, content: message})

    messages = messages ++ [user_message]

    _assistant_message = Chat.new_assistant_message(messages)

    socket = assign(socket, :messages, Chat.all_messages())

    {:noreply, socket}
  end
end
