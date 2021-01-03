defmodule DB.Repo.Migrations.CreateUserContactsTable do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE IF NOT EXISTS users_contacts(
      users_id INTEGER REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
      contacts_id INTEGER REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
      contact_name VARCHAR,
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
