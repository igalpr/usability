class RemoveUncommentableFromNews < ActiveRecord::Migration[4.2]
  def change
    remove_column :news, :uncommentable, :boolean, default: false
  end
end
