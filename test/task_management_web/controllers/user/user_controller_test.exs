defmodule TaskManagementWeb.User.UserControllerTest do
  use TaskManagementWeb.ConnCase, async: true

  alias TaskManagement.Domain.Interactors.UserInteractor

  describe "POST /users" do
    test "creates a new user with valid attributes", %{conn: conn} do
      valid_attrs = %{"name" => "kiran", "email" => "kiran@example.com"}

      conn =
        post(
          conn,
          ~p"/api/v1/users",
          %{"name" => "kiran", "email" => "kiran@example.com"}
        )

      response = json_response(conn, 201)

      assert %{
               "message" => "user successfully created",
               "user_id" => user_id,
               "user" => ^valid_attrs
             } = response

      assert is_integer(user_id) or is_binary(user_id)

      assert {:ok, _user} = UserInteractor.get_user_by_id(user_id)
    end

    test "returns error with invalid attributes", %{conn: conn} do
      invalid_attrs = %{"name" => "", "email" => "invalid_email"}

      conn =
        post(
          conn,
          ~p"/api/v1/users",
          invalid_attrs
        )

      assert json_response(conn, 400) == %{
               "error" => %{
                 "name" => ["can't be blank"],
                 "email" => ["has invalid format"]
               }
             }
    end

    test "handles missing parameters gracefully", %{conn: conn} do
      conn =
        post(
          conn,
          ~p"/api/v1/users",
          %{}
        )

      assert json_response(conn, 400) == %{
               "error" => "Invalid request body."
             }
    end

    test "handles duplicate email gracefully", %{conn: conn} do
      UserInteractor.insert_user(%{name: "Jane Doe", email: "duplicate@example.com"})

      attrs = %{"name" => "kiran", "email" => "duplicate@example.com"}

      conn =
        post(
          conn,
          ~p"/api/v1/users",
          attrs
        )

      assert json_response(conn, 400) == %{
               "error" => %{
                 "email" => ["has already been taken"]
               }
             }
    end
  end
end
