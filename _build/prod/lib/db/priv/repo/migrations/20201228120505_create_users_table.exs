defmodule DB.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def up do
  execute """
  CREATE TABLE IF NOT EXISTS users (

  id SERIAL PRIMARY KEY,
  username VARCHAR not null unique,
  hashed_password VARCHAR,
  inserted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

  );
  """
  end

  def down do
    execute """
    DROP TABLE IF EXISTS users;
    """
  end
end
