defmodule DB.Repo.Migrations.UpdateMessagesTable do
  use Ecto.Migration

  def up do
    execute """
    ALTER TABLE IF EXISTS messages
    ADD COLUMN received BOOLEAN,
    ADD COLUMN seen BOOLEAN;
    """
  end

  def down do
    execute """
    ALTER TABLE IF EXISTS messages
    DROP COLUMN IF EXISTS received default false,
    DROP COLUMN IF EXISTS received default false;
    """
  end
end
