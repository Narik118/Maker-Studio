defmodule TaskManagement.Domain.Schemas.TaskSchemaTest do
  @moduledoc """
  Tests for TaskSchema
  """
  use TaskManagement.DataCase
  alias TaskManagement.Domain.Schemas.TaskSchema
  alias TaskManagement.Domain.Schemas.UserSchema

  describe "changeset/2" do
    setup do
      user =
        %UserSchema{
          name: "Test User",
          email: "testuser@example.com"
        }
        |> UserSchema.changeset(%{})
        |> Repo.insert!()

      %{user: user}
    end

    test "creates a changeset with valid attributes", %{user: user} do
      attrs = %{
        title: "Sample Task",
        description: "This is a sample task.",
        due_date: ~U[2024-12-31T23:59:59Z],
        status: "To Do",
        user_id: user.id
      }

      changeset =
        %TaskSchema{}
        |> TaskSchema.changeset(attrs)

      assert changeset.valid?
      assert changeset.changes == attrs
    end

    test "fails with missing required attributes", %{user: _user} do
      attrs = %{
        title: "Sample Task",
        description: "This is a sample task.",
        status: "To Do"
        # Missing due_date and user_id
      }

      changeset =
        %TaskSchema{}
        |> TaskSchema.changeset(attrs)

      refute changeset.valid?
      assert %{due_date: ["can't be blank"], user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "fails with invalid status", %{user: user} do
      attrs = %{
        title: "Sample Task",
        description: "This is a sample task.",
        due_date: ~U[2024-12-31T23:59:59Z],
        status: "Invalid Status",
        user_id: user.id
      }

      changeset =
        %TaskSchema{}
        |> TaskSchema.changeset(attrs)

      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    # test "fails to insert with non-existent user" do
    #   attrs = %{
    #     title: "Sample Task",
    #     description: "This is a sample task.",
    #     due_date: ~U[2024-12-31T23:59:59Z],
    #     status: "To Do",
    #     user_id: Ecto.UUID.generate()
    #   }

    #   changeset =
    #     %TaskSchema{}
    #     |> TaskSchema.changeset(attrs)
    #     |> Repo.insert()

    #   assert {:error, changeset} = changeset
    #   assert %{user_id: ["does not exist"]} = errors_on(changeset)
    # end

    test "successfully inserts a task", %{user: user} do
      attrs = %{
        title: "Sample Task",
        description: "This is a sample task.",
        due_date: ~U[2024-12-31T23:59:59Z],
        status: "To Do",
        user_id: user.id
      }

      assert {:ok, %TaskSchema{} = task} =
               TaskSchema.changeset(%TaskSchema{}, attrs) |> Repo.insert()

      assert task.title == "Sample Task"
    end

    test "fails with empty string for required fields", %{user: user} do
      attrs = %{
        title: "",
        description: "",
        # `due_date` should not be nil
        due_date: nil,
        status: "",
        user_id: user.id
      }

      changeset =
        %TaskSchema{}
        |> TaskSchema.changeset(attrs)

      refute changeset.valid?

      assert %{
               title: ["can't be blank"],
               description: ["can't be blank"],
               due_date: ["can't be blank"],
               status: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "fails with invalid date format", %{user: user} do
      attrs = %{
        title: "Sample Task",
        description: "This is a sample task.",
        # Invalid format
        due_date: "invalid_date_format",
        status: "To Do",
        user_id: user.id
      }

      changeset =
        %TaskSchema{}
        |> TaskSchema.changeset(attrs)

      refute changeset.valid?
      assert %{due_date: ["is invalid"]} = errors_on(changeset)
    end

    test "accepts very distant future dates", %{user: user} do
      attrs = %{
        title: "Future Task",
        description: "This is a task far in the future.",
        due_date: ~U[3000-12-31T23:59:59Z],
        status: "To Do",
        user_id: user.id
      }

      changeset =
        %TaskSchema{}
        |> TaskSchema.changeset(attrs)

      assert changeset.valid?
    end

    test "accepts very distant past dates", %{user: user} do
      attrs = %{
        title: "Past Task",
        description: "This is a task from the past.",
        due_date: ~U[1000-01-01T00:00:00Z],
        status: "To Do",
        user_id: user.id
      }

      changeset =
        %TaskSchema{}
        |> TaskSchema.changeset(attrs)

      assert changeset.valid?
    end
  end
end
