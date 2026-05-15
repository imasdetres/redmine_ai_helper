# frozen_string_literal: true

module RedmineAiHelper
  module Util
    # Utility class for checking AI Helper availability on projects.
    class PermissionChecker
      # Check if AI Helper is available for the given project and user.
      # Returns true when the project exists and the user is logged in.
      # The ai_helper project module does NOT need to be explicitly enabled;
      # the FAB and chat are available on every project page.
      def self.module_enabled?(project:, user: User.current, permission: :view_ai_helper)
        !!(project&.id && user.logged?)
      end
    end
  end
end
