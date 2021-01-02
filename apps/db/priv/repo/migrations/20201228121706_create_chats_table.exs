defmodule DB.Repo.Migrations.CreateChatsTable do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE IF NOT EXISTS chats (
      id SERIAL PRIMARY KEY,
      chat_name VARCHAR,
      chat_type VARCHAR,
      inserted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

    );
    """
  end

  def down do
    execute """
    DROP TABLE IF EXISTS chats;
    """
  end
end
