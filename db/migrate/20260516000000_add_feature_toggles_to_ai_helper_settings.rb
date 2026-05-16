# frozen_string_literal: true

# Add per-feature toggle columns to ai_helper_settings.
# All features default to enabled (true) so existing installations
# retain current behaviour after the migration runs.
class AddFeatureTogglesToAiHelperSettings < ActiveRecord::Migration[6.1]
  def change
    change_table :ai_helper_settings, bulk: true do |t|
      t.boolean :feature_chat_enabled, default: true, null: false
      t.boolean :feature_issue_summary_enabled, default: true, null: false
      t.boolean :feature_wiki_summary_enabled, default: true, null: false
      t.boolean :feature_issue_reply_enabled, default: true, null: false
      t.boolean :feature_subtask_generation_enabled, default: true, null: false
      t.boolean :feature_auto_completion_enabled, default: true, null: false
      t.boolean :feature_typo_check_enabled, default: true, null: false
      t.boolean :feature_assignment_suggestion_enabled, default: true, null: false
      t.boolean :feature_health_report_enabled, default: true, null: false
      t.boolean :feature_stuff_todo_enabled, default: true, null: false
      t.boolean :feature_duplicate_check_enabled, default: true, null: false
    end
  end
end
