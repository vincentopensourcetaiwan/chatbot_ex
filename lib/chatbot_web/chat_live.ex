defmodule ChatbotWeb.ChatLive do
  use ChatbotWeb, :live_view
  alias Chatbot.Chat

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :messages, Chat.all_messages())}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= for m <- @messages do %>
      <p>role: <%= m.role %> content: <%= m.content %></p>
    <% end %>
    """
  end
end
