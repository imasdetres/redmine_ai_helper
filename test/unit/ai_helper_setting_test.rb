require_relative "../test_helper"

class AiHelperSettingTest < ActiveSupport::TestCase
  setup do
    AiHelperSetting.delete_all
    @setting = AiHelperSetting.find_or_create
  end

  context "attachment_send_enabled" do
    should "default to false" do
      assert_equal false, @setting.attachment_send_enabled
    end

    should "be settable to true" do
      @setting.attachment_send_enabled = true
      @setting.save!
      @setting.reload

      assert_equal true, @setting.attachment_send_enabled
    end
  end

  context "attachment_max_size_mb" do
    should "default to 3" do
      assert_equal 3, @setting.attachment_max_size_mb
    end

    should "validate numericality when attachment_send_enabled is true" do
      @setting.attachment_send_enabled = true
      @setting.attachment_max_size_mb = 0

      assert_not @setting.valid?
      assert_predicate @setting.errors[:attachment_max_size_mb], :present?
    end

    should "validate integer only when attachment_send_enabled is true" do
      @setting.attachment_send_enabled = true
      @setting.attachment_max_size_mb = 1.5

      assert_not @setting.valid?
      assert_predicate @setting.errors[:attachment_max_size_mb], :present?
    end

    should "be valid with value >= 1 when attachment_send_enabled is true" do
      @setting.attachment_send_enabled = true
      @setting.attachment_max_size_mb = 1

      assert_predicate @setting, :valid?
    end

    should "skip validation when attachment_send_enabled is false" do
      @setting.attachment_send_enabled = false
      @setting.attachment_max_size_mb = 0

      assert_predicate @setting, :valid?
    end
  end

  context "class method attachment_send_enabled?" do
    should "return false when setting is disabled" do
      @setting.update!(attachment_send_enabled: false)

      assert_equal false, AiHelperSetting.attachment_send_enabled?
    end

    should "return true when setting is enabled" do
      @setting.update!(attachment_send_enabled: true)

      assert_equal true, AiHelperSetting.attachment_send_enabled?
    end
  end

  context "class method attachment_max_size_mb" do
    should "return the configured value" do
      @setting.update!(attachment_send_enabled: true, attachment_max_size_mb: 5)

      assert_equal 5, AiHelperSetting.attachment_max_size_mb
    end

    should "return default value" do
      assert_equal 3, AiHelperSetting.attachment_max_size_mb
    end
  end

  context "instance method attachment_send_enabled?" do
    should "return true when attachment_send_enabled is true" do
      @setting.attachment_send_enabled = true

      assert_predicate @setting, :attachment_send_enabled?
    end

    should "return false when attachment_send_enabled is false" do
      @setting.attachment_send_enabled = false

      assert_not @setting.attachment_send_enabled?
    end
  end

  context "use_vector_model_profile validation" do
    setup do
      @vector_profile = AiHelperModelProfile.create!(
        name: "Vector Profile",
        access_key: "vec_key",
        llm_type: "OpenAI",
        llm_model: "text-embedding-3-large"
      )
    end

    teardown do
      @vector_profile.destroy if @vector_profile.persisted?
    end

    should "be invalid when use_vector_model_profile is true, vector_search_enabled is true, but vector_model_profile_id is blank" do
      @setting.vector_search_enabled = true
      @setting.vector_search_uri = "http://localhost:6333"
      @setting.use_vector_model_profile = true
      @setting.vector_model_profile_id = nil

      assert_not @setting.valid?
      assert_predicate @setting.errors[:vector_model_profile_id], :present?
    end

    should "be valid when use_vector_model_profile is true, vector_search_enabled is true, and vector_model_profile_id is set" do
      @setting.vector_search_enabled = true
      @setting.vector_search_uri = "http://localhost:6333"
      @setting.use_vector_model_profile = true
      @setting.vector_model_profile_id = @vector_profile.id

      assert_predicate @setting, :valid?
    end

    should "be valid when use_vector_model_profile is false even without vector_model_profile_id" do
      @setting.use_vector_model_profile = false
      @setting.vector_model_profile_id = nil

      assert_predicate @setting, :valid?
    end

    should "skip vector_model_profile_id validation when vector_search_enabled is false" do
      @setting.vector_search_enabled = false
      @setting.use_vector_model_profile = true
      @setting.vector_model_profile_id = nil

      assert_predicate @setting, :valid?
    end
  end

  context "before_save clear_vector_model_profile_id_if_disabled" do
    setup do
      @vector_profile = AiHelperModelProfile.create!(
        name: "Vector Profile",
        access_key: "vec_key",
        llm_type: "OpenAI",
        llm_model: "text-embedding-3-large"
      )
    end

    teardown do
      @vector_profile.destroy if @vector_profile.persisted?
    end

    should "clear vector_model_profile_id when use_vector_model_profile is set to false" do
      @setting.update_columns(use_vector_model_profile: true, vector_model_profile_id: @vector_profile.id)
      @setting.reload
      @setting.use_vector_model_profile = false
      @setting.save!
      @setting.reload

      assert_nil @setting.vector_model_profile_id
    end

    should "not clear vector_model_profile_id when use_vector_model_profile is true" do
      @setting.vector_search_enabled = true
      @setting.vector_search_uri = "http://localhost:6333"
      @setting.use_vector_model_profile = true
      @setting.vector_model_profile_id = @vector_profile.id
      @setting.save!
      @setting.reload

      assert_equal @vector_profile.id, @setting.vector_model_profile_id
    end

    should "clear use_vector_model_profile and vector_model_profile_id when vector_search_enabled is set to false" do
      @setting.update_columns(
        vector_search_enabled: true,
        use_vector_model_profile: true,
        vector_model_profile_id: @vector_profile.id
      )
      @setting.reload
      @setting.vector_search_enabled = false
      @setting.save!
      @setting.reload

      assert_equal false, @setting.use_vector_model_profile
      assert_nil @setting.vector_model_profile_id
    end
  end

  # ─── mcp_server_enabled (T025) ────────────────────────────────────────────

  context "mcp_server_enabled" do
    should "default to false" do
      assert_equal false, @setting.mcp_server_enabled
    end

    should "be readable and writable" do
      @setting.mcp_server_enabled = true
      @setting.save!
      @setting.reload

      assert_equal true, @setting.mcp_server_enabled
    end

    should "be settable to false" do
      @setting.update_column(:mcp_server_enabled, true)
      @setting.mcp_server_enabled = false
      @setting.save!
      @setting.reload

      assert_equal false, @setting.mcp_server_enabled
    end
  end

  context "class method mcp_server_enabled?" do
    should "return false when mcp_server_enabled is false" do
      @setting.update!(mcp_server_enabled: false)

      assert_equal false, AiHelperSetting.mcp_server_enabled?
    end

    should "return true when mcp_server_enabled is true" do
      @setting.update!(mcp_server_enabled: true)

      assert_equal true, AiHelperSetting.mcp_server_enabled?
    end
  end

  # ─── Feature toggles ─────────────────────────────────────────────────────

  context "FEATURE_TOGGLES constant" do
    should "contain all expected feature toggle names" do
      expected = %w[
        feature_chat_enabled
        feature_issue_summary_enabled
        feature_wiki_summary_enabled
        feature_issue_reply_enabled
        feature_subtask_generation_enabled
        feature_auto_completion_enabled
        feature_typo_check_enabled
        feature_assignment_suggestion_enabled
        feature_health_report_enabled
        feature_stuff_todo_enabled
        feature_duplicate_check_enabled
      ]

      assert_equal expected, AiHelperSetting::FEATURE_TOGGLES
    end

    should "be frozen" do
      assert_predicate AiHelperSetting::FEATURE_TOGGLES, :frozen?
    end
  end

  context "feature toggle defaults" do
    should "default all feature toggles to true" do
      AiHelperSetting::FEATURE_TOGGLES.each do |toggle|
        assert_equal true, @setting.public_send(toggle),
          "Expected #{toggle} to default to true"
      end
    end
  end

  context "feature toggle instance read/write" do
    AiHelperSetting::FEATURE_TOGGLES.each do |toggle|
      should "allow setting #{toggle} to false and back to true" do
        @setting.public_send(:"#{toggle}=", false)
        @setting.save!
        @setting.reload

        assert_equal false, @setting.public_send(toggle)

        @setting.public_send(:"#{toggle}=", true)
        @setting.save!
        @setting.reload

        assert_equal true, @setting.public_send(toggle)
      end
    end
  end

  context "feature toggle class methods" do
    AiHelperSetting::FEATURE_TOGGLES.each do |toggle|
      should "define class method #{toggle}? that returns true when enabled" do
        @setting.update!(toggle => true)

        assert_equal true, AiHelperSetting.public_send(:"#{toggle}?")
      end

      should "define class method #{toggle}? that returns false when disabled" do
        @setting.update!(toggle => false)

        assert_equal false, AiHelperSetting.public_send(:"#{toggle}?")
      end
    end
  end

  context "feature toggles safe_attributes" do
    should "include all feature toggles in safe_attributes" do
      AiHelperSetting::FEATURE_TOGGLES.each do |toggle|
        @setting.safe_attributes = { toggle => "0" }
        @setting.save!
        @setting.reload

        assert_equal false, @setting.public_send(toggle),
          "Expected #{toggle} to be settable via safe_attributes to false"

        @setting.safe_attributes = { toggle => "1" }
        @setting.save!
        @setting.reload

        assert_equal true, @setting.public_send(toggle),
          "Expected #{toggle} to be settable via safe_attributes to true"
      end
    end
  end
end
