# frozen_string_literal: true

# Add opt-in "orchestrator passthrough" mode to ai_helper_settings.
#
# When enabled, the chat feature bypasses the multi-agent LeaderAgent pipeline
# (goal/steps JSON planning + per-agent tool loops) and forwards the user's
# message to the configured backend in a SINGLE, tool-less call.
#
# This is intended for deployments where the backend is ITSELF a full RAG
# orchestrator (e.g. the i+D3 "Oráculo"): running the plugin's own agent loop
# on top of another orchestrator causes double orchestration — token blow-up,
# system-prompt collisions and lost end-user identity. Defaults to false so
# existing installations keep the current multi-agent behaviour.
class AddOrchestratorPassthroughToAiHelperSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :ai_helper_settings, :orchestrator_passthrough_enabled, :boolean,
      default: false, null: false
  end
end
