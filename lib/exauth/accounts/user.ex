defmodule Exauth.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exauth.AuthTokens.AuthToken

  @derive {Jason.Encoder, except: [:__meta__, :auth_tokens, :password]}
  schema "users" do
    field :email, :string
    field :password, :string
    field :username, :string

    has_many :auth_tokens, AuthToken

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_length(:password, min: 8, max: 30)
    |> validate_length(:username, min: 3, max: 20)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> update_change(:email, fn email -> String.downcase(email) end)
    |> update_change(:username, &String.downcase(&1))
    |> hash_password()
  end

  defp hash_password(changeset) do
    changeset
    |> case do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password, Pbkdf2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
