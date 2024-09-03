defmodule TaskManagementWeb.Task.TaskControllerTest do
  use TaskManagementWeb.ConnCase, async: true

  alias TaskManagementWeb.Auth.TokenClient
  alias TaskManagement.Domain.Interactors.{TaskInteractor, UserInteractor}

  setup do
    user_attrs = %{"name" => "John Doe", "email" => "john.doe@example.com"}
    {:ok, user} = UserInteractor.insert_user(user_attrs)
    user_id = user.id
    token = TokenClient.generate_new_token(user_id)
    %{user_id: user_id, token: token}
  end

  describe "POST /users/:user_id/tasks" do
    test "creates a new task with valid attributes", %{conn: conn, user_id: user_id, token: token} do
      valid_attrs = %{
        "description" => "Task description",
        "due_date" => ~U[2024-12-31T23:59:59Z],
        "status" => "To Do",
        "title" => "Task title",
        "user_id" => user_id
      }

      conn =
        post(
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
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

    test "handles missing parameters gracefully", %{conn: conn, user_id: user_id, token: token} do
      conn =
        post(
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
          ~p"/api/v1/users/#{user_id}/tasks",
          %{"user_id" => user_id}
        )

      assert json_response(conn, 400) == %{
               "error" => "Invalid request body."
             }
    end

    test "handles unauthorized access due to invalid token", %{conn: conn, user_id: user_id} do
      invalid_token = "invalid-token"

      invalid_attrs = %{
        "description" => "Task description",
        "due_date" => ~U[2024-12-31T23:59:59Z],
        "status" => "To Do",
        "title" => "Task title",
        "user_id" => user_id
      }

      conn =
        post(
          conn
          |> put_req_header("authorization", "Bearer #{invalid_token}"),
          ~p"/api/v1/users/#{user_id}/tasks",
          invalid_attrs
        )

      assert json_response(conn, 403) == %{
               "error" => "Unauthorized or Invalid token"
             }
    end
  end

  describe "GET /users/:user_id/tasks/:task_id" do
    test "retrieves a specific task", %{conn: conn, user_id: user_id, token: token} do
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
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
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

    test "returns error for a non-existent task", %{conn: conn, user_id: user_id, token: token} do
      conn =
        get(
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
          "/api/v1/users/#{user_id}/tasks/invalid-id"
        )

      assert json_response(conn, 401) == %{
               "error" => "Requested task could not be found. Please recheck user id and task id"
             }
    end

    test "handles unauthorized access due to invalid token", %{conn: conn, user_id: user_id} do
      invalid_token = "invalid-token"

      conn =
        get(
          conn
          |> put_req_header("authorization", "Bearer #{invalid_token}"),
          ~p"/api/v1/users/#{user_id}/tasks"
        )

      assert json_response(conn, 403) == %{
               "error" => "Unauthorized or Invalid token"
             }
    end
  end

  describe "PUT /users/:user_id/tasks/:task_id" do
    test "successfully updates a task with valid parameters", %{
      conn: conn,
      user_id: user_id,
      token: token
    } do
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
        "status" => "Done",
        "user_id" => user_id
      }

      conn =
        put(
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
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

    test "returns error with invalid task_id", %{conn: conn, user_id: user_id, token: token} do
      invalid_update_attrs = %{
        "title" => "Updated title",
        "user_id" => user_id
      }

      conn =
        put(
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
          "/api/v1/users/#{user_id}/tasks/invalid-id",
          invalid_update_attrs
        )

      assert json_response(conn, 400) == %{"error" => "Invalid request body."}
    end

    test "returns error with missing parameters", %{conn: conn, user_id: user_id, token: token} do
      conn =
        put(
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
          "/api/v1/users/#{user_id}/tasks/5678",
          %{"user_id" => user_id}
        )

      assert json_response(conn, 400) == %{
               "error" => "Invalid request body."
             }
    end

    test "returns error for unauthorized update attempt", %{conn: conn, user_id: user_id} do
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

      unauthorized_token = "unauthorized-token"

      invalid_update_attrs = %{
        "title" => "Updated title",
        "description" => "Updated description",
        "due_date" => ~U[2024-12-31T23:59:59Z],
        "status" => "Done",
        "user_id" => user_id
      }

      conn =
        put(
          conn
          |> put_req_header("authorization", "Bearer #{unauthorized_token}"),
          "/api/v1/users/#{user_id}/tasks/#{task_id}",
          invalid_update_attrs
        )

      assert json_response(conn, 403) == %{
               "error" => "Unauthorized or Invalid token"
             }
    end
  end

  describe "DELETE /users/:user_id/tasks/:task_id" do
    test "successfully deletes a task", %{conn: conn, user_id: user_id, token: token} do
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
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
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

    test "returns error for non-existent task", %{conn: conn, user_id: user_id, token: token} do
      conn =
        delete(
          conn
          |> put_req_header("authorization", "Bearer #{token}"),
          "/api/v1/users/#{user_id}/tasks/invalid-id"
        )

      assert json_response(conn, 400) == %{"error" => "delete_failed"}
    end

    test "returns error for unauthorized delete attempt", %{conn: conn, user_id: user_id} do
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

      unauthorized_token = "unauthorized-token"

      conn =
        delete(
          conn
          |> put_req_header("authorization", "Bearer #{unauthorized_token}"),
          "/api/v1/users/#{user_id}/tasks/#{task_id}"
        )

      assert json_response(conn, 403) == %{
               "error" => "Unauthorized or Invalid token"
             }
    end
  end
end
