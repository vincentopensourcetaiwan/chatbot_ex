defmodule Chatbot.Repo.Migrations.CreateMessagesTable do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TYPE role
      AS ENUM ('user', 'assistant', 'system')
      """,
      """
      DROP TYPE role
      """
    )

    create table(:messages) do
      add :role, :role, null: false
      add :content, :text, null: false

      timestamps()
    end
  end
end
