defmodule ChatbotWeb.ChatLive do
  use ChatbotWeb, :live_view
  alias Chatbot.Chat
  import ChatbotWeb.CoreComponents

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:messages, Chat.all_messages())
      |> assign(:latest_assistant, nil)
      |> assign(:form, to_form(%{"message" => ""}))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= for m <- @messages do %>
      <p>role: <%= m.role %> content: <%= m.content %></p>
    <% end %>

    <.async_result :let={latest_assistant} :if={assigns[:latest_assistant]} assign={@latest_assistant}>
      <:loading>...</:loading>
      <:failed :let={_failure}>I did something stupid and failed.</:failed>
      <%= if latest_assistant do %>
        <p>role: <%= latest_assistant.role %> content: <%= latest_assistant.content %></p>
      <% end %>
    </.async_result>

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

    socket =
      socket
      |> assign(:messages, Chat.all_messages())
      |> assign_async(
        :latest_assistant,
        fn ->
          {:ok, %{latest_assistant: Chat.new_assistant_message(messages)}}
        end,
        reset: true
      )

    {:noreply, socket}
  end
end
