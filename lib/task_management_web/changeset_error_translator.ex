defmodule TaskManagementWeb.ChangesetErrorTranslator do
  @moduledoc """
  module to translate changeset errors into readable format
  """
  alias Ecto.Changeset

  @spec translate_error(Ecto.Changeset.t()) :: map()
  def translate_error(changeset) do
    Changeset.traverse_errors(changeset, &convert_error/1)
  end

  def convert_error({msg, opts}) do
    case opts[:count] do
      nil -> Gettext.dgettext(TaskManagementWeb.Gettext, "errors", msg, opts)
      count -> Gettext.dngettext(TaskManagementWeb.Gettext, "errors", msg, msg, count, opts)
    end
  end
end
