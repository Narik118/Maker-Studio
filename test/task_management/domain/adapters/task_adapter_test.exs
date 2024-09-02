defmodule TaskManagement.Domain.Adapters.TaskAdapterTest do
  use ExUnit.Case
  alias TaskManagement.Repo
  alias TaskManagement.Domain.Schemas.TaskSchema
  alias TaskManagement.Domain.Adapters.TaskAdapter
  alias TaskManagement.Domain.Interactors.UserInteractor

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    # Create a user
    user_attrs = %{"name" => "John Doe", "email" => "john.doe@example.com"}
    {:ok, user} = UserInteractor.insert_user(user_attrs)
    user_id = user.id

    # Create a task
    task_attrs = %{
      title: "Sample Task",
      description: "This is a sample task.",
      due_date: ~U[2024-12-31T23:59:59Z],
      status: "To Do",
      user_id: user_id
    }

    {:ok, task} = TaskAdapter.insert_task(task_attrs)

    %{user_id: user_id, task: task}
  end

  describe "insert_task/1" do
    test "inserts a new task with valid attributes", %{user_id: user_id} do
      attrs = %{
        "title" => "Another Task",
        "description" => "This is another task.",
        "due_date" => ~U[2024-12-31T23:59:59Z],
        "status" => "To Do",
        "user_id" => user_id
      }

      assert {:ok, %TaskSchema{} = task} = TaskAdapter.insert_task(attrs)
      assert task.title == "Another Task"
      assert task.user_id == user_id
    end

    test "fails to insert a new task with invalid attributes" do
      invalid_attrs = %{
        "title" => "",
        "description" => "Task description",
        "due_date" => "invalid-date",
        "status" => "pending"
      }

      assert {:error, _changeset} = TaskAdapter.insert_task(invalid_attrs)
    end
  end

  describe "get_task_by_id/2" do
    test "retrieves a task by id for a user", %{user_id: user_id, task: task} do
      assert {:ok, %TaskSchema{} = retrieved_task} = TaskAdapter.get_task_by_id(user_id, task.id)
      assert retrieved_task.id == task.id
    end

    test "returns :error, :not_found when the task does not exist", %{user_id: user_id} do
      # non existing task id
      assert {:error, :not_found} = TaskAdapter.get_task_by_id(user_id, "3298385098470")
    end
  end

  describe "update_task_by_id/3" do
    test "updates a task with valid attributes", %{user_id: user_id, task: task} do
      updated_attrs = %{
        "title" => "Updated Task",
        "description" => "Updated description",
        "due_date" => ~U[2024-12-15T23:59:59Z],
        "status" => "Done"
      }

      assert {:ok, :updated} = TaskAdapter.update_task_by_id(user_id, task.id, updated_attrs)

      updated_task = Repo.get(TaskSchema, task.id)
      assert updated_task.title == "Updated Task"
      assert updated_task.status == "Done"
    end

    test "returns :error, :unknown_error if the task exists but update fails", %{
      user_id: user_id,
      task: task
    } do
      assert {:error, :unknown_error} =
               TaskAdapter.update_task_by_id(user_id, task.id, %{"title" => ""})
    end
  end

  describe "get_users_tasks/1" do
    test "retrieves all tasks for a user", %{user_id: user_id} do
      # Insert another task for the same user
      attrs = %{
        title: "Another Task",
        description: "This is another task.",
        due_date: ~U[2024-12-31T23:59:59Z],
        status: "To Do",
        user_id: user_id
      }

      TaskAdapter.insert_task(attrs)

      tasks = TaskAdapter.get_users_tasks(user_id)
      assert length(tasks) == 2
    end

    test "returns an empty list if the user has no tasks", %{user_id: user_id} do
      Repo.delete_all(TaskSchema)
      tasks = TaskAdapter.get_users_tasks(user_id)
      assert tasks == []
    end
  end

  describe "delete_task_by_id/1" do
    test "deletes a task by id", %{task: task} do
      assert {:ok, %TaskSchema{} = deleted_task} = TaskAdapter.delete_task_by_id(task.id)
      assert deleted_task.id == task.id
      assert Repo.get(TaskSchema, task.id) == nil
    end

    test "returns :error, :not_found if the task does not exist" do
      # not existing task id
      assert {:error, :not_found} = TaskAdapter.delete_task_by_id("3286329875")
    end
  end
end
