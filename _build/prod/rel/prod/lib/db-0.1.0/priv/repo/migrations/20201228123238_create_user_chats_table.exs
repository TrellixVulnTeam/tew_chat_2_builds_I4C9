defmodule DB.Repo.Migrations.CreateUserChatsTable do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE IF NOT EXISTS users_chats(
      users_id INTEGER REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
      chats_id INTEGER REFERENCES chats(id) ON UPDATE CASCADE ON DELETE CASCADE,
      CONSTRAINT users_chats_pkey PRIMARY KEY (users_id, chats_id)

    );
    """
  end

  def down do
    execute """
    DROP TABLE IF EXISTS users_chats;
    """
  end
end
