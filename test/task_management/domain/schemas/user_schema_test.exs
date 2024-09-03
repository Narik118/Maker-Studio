defmodule TaskManagement.Domain.Schemas.UserSchemaTest do
  @moduledoc """
  Tests for UserSchema
  """
  use TaskManagement.DataCase
  alias TaskManagement.Domain.Schemas.UserSchema

  describe "changeset/2 -" do
    test "successfully creates a changeset with valid attributes" do
      attrs = %{name: "kiran srigiri", email: "kiransri118@gmail.com", password: "pass@123"}
      changeset = UserSchema.changeset(%UserSchema{}, attrs)

      hash = Argon2.hash_pwd_salt(attrs.password)

      assert changeset.valid?
    end

    test "fails to create a changeset with missing required attributes" do
      attrs = %{}
      changeset = UserSchema.changeset(%UserSchema{}, attrs)

      refute changeset.valid?
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "handles unexpected data types" do
      attrs = %{name: 123, email: :invalid}
      changeset = UserSchema.changeset(%UserSchema{}, attrs)

      refute changeset.valid?
      assert %{name: ["is invalid"]} = errors_on(changeset)
      assert %{email: ["is invalid"]} = errors_on(changeset)
    end

    test "accepts valid email formats" do
      valid_emails = [
        "example@example.com",
        "user.name@subdomain.example.com",
        "user+name@domain.co"
      ]

      Enum.each(valid_emails, fn email ->
        attrs = %{name: "valid name", email: email, password: "pass@123"}
        changeset = UserSchema.changeset(%UserSchema{}, attrs)

        assert changeset.valid?
      end)
    end

    test "rejects invalid email formats" do
      invalid_emails = [
        "plainaddress",
        "@missingusername.com",
        "username@.com",
        "username@domain",
        "username@domain,com"
      ]

      Enum.each(invalid_emails, fn email ->
        attrs = %{name: "valid name", email: email}
        changeset = UserSchema.changeset(%UserSchema{}, attrs)

        refute changeset.valid?
        assert %{email: ["has invalid format"]} = errors_on(changeset)
      end)
    end

    test "ensures email uniqueness" do
      existing_user_attrs = %{name: "existing user", email: "unique@example.com", password: "pass@123"}

      {:ok, _existing_user} =
        %UserSchema{}
        |> UserSchema.changeset(existing_user_attrs)
        |> Repo.insert()

      new_user_attrs = %{name: "new user", email: "unique@example.com", password: "pass@123"}

      changeset =
        %UserSchema{}
        |> UserSchema.changeset(new_user_attrs)
        |> Repo.insert()

      assert {:error, changeset} = changeset
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
