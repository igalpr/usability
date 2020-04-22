class AddUncommentableToNews < ActiveRecord::Migration[4.2]
  def change
    add_column :news, :uncommentable, :boolean,  default: false
  end
end
