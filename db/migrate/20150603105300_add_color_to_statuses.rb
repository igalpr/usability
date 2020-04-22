class AddColorToStatuses < ActiveRecord::Migration[4.2]
  def down
    if !Redmine::Plugin.installed?(:luxury_buttons) && IssueStatus.column_names.include?('us_color')
      remove_column :issue_statuses, :us_color
    end
  end
end
