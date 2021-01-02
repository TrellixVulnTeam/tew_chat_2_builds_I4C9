defmodule DB.Repo.Migrations.CreateUserContactsTable do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE IF NOT EXISTS users_contacts(
      users_id INTEGER REFERENCES users(id),
      contacts_id INTEGER REFERENCES users(id),
      CONSTRAINT users_contacts_pkey PRIMARY KEY (users_id, contacts_id)
    );
    """
  end

  def down do
    execute """
    DROP TABLE IF EXISTS users_contacts;
    """
  end
end
