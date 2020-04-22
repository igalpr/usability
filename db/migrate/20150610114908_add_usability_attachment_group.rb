class AddUsabilityAttachmentGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :us_group_id, :integer, null: true
  end
end