# frozen_string_literal: true

# Move the "orchestrator passthrough" flag from the global ai_helper_settings
# to each ai_helper_model_profiles row.
#
# Rationale: whether the backend is itself a RAG orchestrator is a property of
# the CONFIGURED ENDPOINT (the model profile), not of the whole installation.
# Per-profile the admin can keep a passthrough profile (e.g. the i+D3 Oráculo)
# alongside normal profiles that still use the multi-agent pipeline, and the
# behaviour follows whichever profile is selected.
class MoveOrchestratorPassthroughToModelProfiles < ActiveRecord::Migration[6.1]
  def up
    add_column :ai_helper_model_profiles, :orchestrator_passthrough_enabled, :boolean,
      default: false, null: false

    # Preserve behaviour: if the global flag was ON, carry it over to the
    # profile currently selected in the settings.
    execute <<~SQL
      UPDATE ai_helper_model_profiles
         SET orchestrator_passthrough_enabled = #{quoted_true}
       WHERE id IN (
         SELECT model_profile_id FROM ai_helper_settings
          WHERE orchestrator_passthrough_enabled = #{quoted_true}
            AND model_profile_id IS NOT NULL
       )
    SQL

    remove_column :ai_helper_settings, :orchestrator_passthrough_enabled
  end

  def down
    add_column :ai_helper_settings, :orchestrator_passthrough_enabled, :boolean,
      default: false, null: false

    execute <<~SQL
      UPDATE ai_helper_settings
         SET orchestrator_passthrough_enabled = #{quoted_true}
       WHERE model_profile_id IN (
         SELECT id FROM ai_helper_model_profiles
          WHERE orchestrator_passthrough_enabled = #{quoted_true}
       )
    SQL

    remove_column :ai_helper_model_profiles, :orchestrator_passthrough_enabled
  end

  private

  def quoted_true
    ActiveRecord::Base.connection.quoted_true
  end
end
