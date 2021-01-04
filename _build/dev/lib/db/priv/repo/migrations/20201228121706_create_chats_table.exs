defmodule DB.Repo.Migrations.CreateChatsTable do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE IF NOT EXISTS chats (
      id SERIAL PRIMARY KEY,
      chat_name VARCHAR,
      chat_type INTEGER DEFAULT 1,
      recipient_id_if_private_chat INTEGER,
      creator_id INTEGER REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
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
