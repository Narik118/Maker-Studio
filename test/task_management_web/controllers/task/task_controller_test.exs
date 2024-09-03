defmodule TaskManagementWeb.Task.TaskControllerTest do
  use TaskManagementWeb.ConnCase, async: true

  alias TaskManagement.Domain.Interactors.{TaskInteractor, UserInteractor}

  setup do
    user_attrs = %{"name" => "John Doe", "email" => "john.doe@example.com"}
    {:ok, user} = UserInteractor.insert_user(user_attrs)
    user_id = user.id

    %{user_id: user_id}
  end

  describe "POST /users/:user_id/tasks" do
    test "creates a new task with valid attributes", %{conn: conn, user_id: user_id} do
      valid_attrs = %{
        "description" => "Task description",
        "due_date" => ~U[2024-12-31T23:59:59Z],
        "status" => "To Do",
        "title" => "Task title"
      }

      conn =
        post(
          conn,
          ~p"/api/v1/users/#{user_id}/tasks",
          valid_attrs
        )

      response = json_response(conn, 201)

      assert %{
               "message" => "Task successfully added",
               "task_id" => task_id
             } = response

      assert is_integer(task_id) or is_binary(task_id)
      assert {:ok, _task} = TaskInteractor.get_task_by_id(user_id, task_id)
    end

    test "handles missing parameters gracefully", %{conn: conn, user_id: user_id} do
      conn =
        post(
          conn,
          ~p"/api/v1/users/#{user_id}/tasks",
          %{}
        )

      assert json_response(conn, 400) == %{
               "error" => "Invalid request body."
             }
    end
  end

  describe "GET /users/:user_id/tasks/:task_id" do
    test "retrieves a specific task", %{conn: conn, user_id: user_id} do
      # Create a task for the user
      {:ok, task} =
        TaskInteractor.insert_task(%{
          "description" => "Task description",
          "due_date" => ~U[2024-12-31T23:59:59Z],
          "status" => "To Do",
          "title" => "Task title",
          "user_id" => user_id
        })

      task_id = task.id

      conn =
        get(
          conn,
          "/api/v1/users/#{user_id}/tasks/#{task_id}"
        )

      response = json_response(conn, 200)

      assert %{
               "message" => %{
                 "id" => _task_id,
                 "title" => "Task title",
                 "description" => "Task description",
                 "status" => "To Do",
                 "due_date" => "2024-12-31T23:59:59Z",
                 "user_id" => _user_id
               }
             } = response
    end

    test "returns error for a non-existent task", %{conn: conn, user_id: user_id} do
      conn =
        get(
          conn,
          "/api/v1/users/#{user_id}/tasks/invalid-id"
        )

      assert json_response(conn, 401) == %{
               "error" => "Requested task could not be found. Please recheck user id and task id"
             }
    end

    test "returns error with missing parameters", %{conn: conn} do
      conn =
        get(
          conn,
          "/api/v1/users/1234/tasks/"
        )

      assert json_response(conn, 401) == %{
               "message" => "No tasks found for the user 1234"
             }
    end
  end

  describe "PUT /users/:user_id/tasks/:task_id" do
    test "successfully updates a task with valid parameters", %{conn: conn, user_id: user_id} do
      # Create a task for the user
      {:ok, task} =
        TaskInteractor.insert_task(%{
          "description" => "Task description",
          "due_date" => ~U[2024-12-31T23:59:59Z],
          "status" => "To Do",
          "title" => "Task title",
          "user_id" => user_id
        })

      task_id = task.id

      valid_update_attrs = %{
        "title" => "Updated title",
        "description" => "Updated description",
        "due_date" => ~U[2024-12-31T23:59:59Z],
        "status" => "Done"
      }

      conn =
        put(
          conn,
          "/api/v1/users/#{user_id}/tasks/#{task_id}",
          valid_update_attrs
        )

      response = json_response(conn, 200)

      assert %{
               "message" => "Task successfully updated",
               "updated_task" => %{
                 "id" => _task_id,
                 "title" => "Updated title",
                 "description" => "Updated description",
                 "due_date" => "2024-12-31T23:59:59Z",
                 "status" => "Done",
                 "user_id" => _user_id
               }
             } = response
    end

    test "returns error with invalid task_id", %{conn: conn, user_id: user_id} do
      invalid_update_attrs = %{
        "title" => "Updated title"
      }

      conn =
        put(
          conn,
          "/api/v1/users/#{user_id}/tasks/invalid-id",
          invalid_update_attrs
        )

      assert json_response(conn, 400) == %{"error" => "Invalid request body."}
    end

    test "returns error with missing parameters", %{conn: conn, user_id: user_id} do
      conn =
        put(
          conn,
          "/api/v1/users/#{user_id}/tasks/5678",
          %{"user_id" => user_id}
        )

      assert json_response(conn, 400) == %{
               "error" => "Invalid request body."
             }
    end
  end

  describe "DELETE /users/:user_id/tasks/:task_id" do
    test "successfully deletes a task", %{conn: conn, user_id: user_id} do
      # Create a task for the user
      {:ok, task} =
        TaskInteractor.insert_task(%{
          "title" => "Another Task",
          "description" => "This is another task.",
          "due_date" => ~U[2024-12-31T23:59:59Z],
          "status" => "To Do",
          "user_id" => user_id
        })

      task_id = task.id

      conn =
        delete(
          conn,
          "/api/v1/users/#{user_id}/tasks/#{task_id}"
        )

      response = json_response(conn, 200)

      assert %{
               "messsage" => "Task deleted successfully",
               "deleted_task" => %{
                 "id" => ^task_id
               }
             } = response
    end

    test "returns error for non-existent task", %{conn: conn, user_id: user_id} do
      conn =
        delete(
          conn,
          ~p"/api/v1/users/#{user_id}/tasks/invalid-id"
        )

      assert json_response(conn, 400) == %{"error" => "not_found"}
    end
  end
end
