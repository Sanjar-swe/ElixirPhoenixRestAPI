defmodule TodoApp.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :is_done, :boolean, default: false

      timestamps()
    end
  end
end
