defmodule TaskManagement.Domain.Adapters.UserAdapterTest do
  use ExUnit.Case
  # import Ecto.Query
  alias TaskManagement.Repo
  alias TaskManagement.Domain.Adapters.UserAdapter
  alias TaskManagement.Domain.Schemas.UserSchema

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    :ok
  end

  describe "insert_user/1" do
    test "inserts a valid user" do
      attrs = %{
        name: "kiran",
        email: "kiran@example.com"
      }

      assert {:ok, %UserSchema{id: id}} = UserAdapter.insert_user(attrs)
      assert %UserSchema{name: "kiran", email: "kiran@example.com"} = Repo.get(UserSchema, id)
    end

    test "fails to insert a user with invalid email" do
      attrs = %{
        name: "kiran",
        email: "invalid_email"
      }

      assert {:error, changeset} = UserAdapter.insert_user(attrs)
      assert %{email: ["has invalid format"]} = errors_on(changeset)
    end

    test "fails to insert a user with missing required fields" do
      attrs = %{
        name: "kiran"
        # Missing email
      }

      assert {:error, changeset} = UserAdapter.insert_user(attrs)
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "ensures email uniqueness" do
      attrs = %{
        name: "kiran",
        email: "kiran@example.com"
      }

      {:ok, _user} = UserAdapter.insert_user(attrs)

      assert {:error, changeset} = UserAdapter.insert_user(attrs)
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "get_user_by_id/1" do
    test "retrieves a user by id" do
      attrs = %{
        name: "kiran",
        email: "kiran@example.com"
      }

      {:ok, user} = UserAdapter.insert_user(attrs)

      assert %UserSchema{id: id} = user

      assert {:ok, %UserSchema{name: "kiran", email: "kiran@example.com"} = _user} =
               UserAdapter.get_user_by_id(id)
    end

    test "returns {:error, :not_found} if the user does not exist" do
      non_existent_id = Ecto.UUID.generate()

      assert {:error, :not_found} == UserAdapter.get_user_by_id(non_existent_id)
    end
  end

  defp errors_on(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, _opts} -> msg end)
  end
end
