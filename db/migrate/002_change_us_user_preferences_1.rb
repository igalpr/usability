class ChangeUsUserPreferences1 < ActiveRecord::Migration[4.2]
  def up
    add_column :user_preferences, :usability, :text
  end
  def down
    remove_column :user_preferences, :usability
  end
end