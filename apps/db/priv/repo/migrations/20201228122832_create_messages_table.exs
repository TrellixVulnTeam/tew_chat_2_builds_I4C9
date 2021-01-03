defmodule DB.Repo.Migrations.CreateMessagesTable do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE IF NOT EXISTS messages(
      id SERIAL PRIMARY KEY,
      msg_text VARCHAR not null,
      inserted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      received BOOLEAN default false,
      seen BOOLEAN default false,
      chats_id INTEGER REFERENCES chats(id) ON UPDATE CASCADE ON DELETE CASCADE,
      sender_id INTEGER REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
    );
    """
  end

  def down do
    execute """
    DROP TABLE IF NOT EXISTS messages;
    """
  end
end
