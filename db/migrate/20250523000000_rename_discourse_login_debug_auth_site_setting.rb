# frozen_string_literal: true

class RenameDiscourseLoginDebugAuthSiteSetting < ActiveRecord::Migration[7.2]
  def up
    execute "UPDATE site_settings SET name = 'discourse_login_client_verbose_logging' WHERE name = 'discourse_login_debug_auth'"
  end

  def down
    execute "UPDATE site_settings SET name = 'discourse_login_debug_auth' WHERE name = 'discourse_login_client_verbose_logging'"
  end
end
