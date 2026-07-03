# SPDX-FileCopyrightText: 2019 ash contributors <https://github.com/ash-project/ash/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Ash.Test.LazyManualSoftDestroy do
  @moduledoc """
  Support resource for `Ash.Test.Actions.BulkDestroyManualUnloadedTest`.

  Defined in `test/support` (compiled to disk) so its manual action module can
  be unloaded at runtime and then reloaded on demand via `Code.ensure_loaded?/1`,
  faithfully reproducing a lazily-loaded manual action module.
  """

  defmodule Manual do
    @moduledoc false
    use Ash.Resource.ManualUpdate

    def update(changeset, _opts, _ctx) do
      {:ok, %{changeset.data | archived: true}}
    end

    def bulk_update(changesets, _opts, _ctx) do
      Enum.map(changesets, fn changeset ->
        {:ok, %{changeset.data | archived: true}, changeset}
      end)
    end
  end

  use Ash.Resource, domain: Ash.Test.Domain, data_layer: Ash.DataLayer.Ets

  ets do
    private? true
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, public?: true

    attribute :archived, :boolean do
      public? true
      default false
      allow_nil? false
    end
  end

  actions do
    default_accept :*
    defaults [:read, create: :*, update: :*]

    destroy :archive do
      primary? true
      soft? true
      require_atomic? false
      manual Manual
    end
  end
end
