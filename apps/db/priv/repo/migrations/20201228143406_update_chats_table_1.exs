defmodule DB.Repo.Migrations.UpdateChatsTable1 do
  use Ecto.Migration

  def up do
    execute """
    ALTER TABLE IF EXISTS chats
    ALTER COLUMN chat_type SET DEFAULT 'private';
    """
  end

  def down do
    execute """
    ALTER TABLE IF EXISTS chats
    ALTER COLUMN chat_type SET DEFAULT null;
    """
  end
end
