class CreateRepos < ActiveRecord::Migration[6.0]
  def change
    create_table :repos do |t|
      t.string :name
      t.string :language
      t.references :user, foreign_key:true
      t.timestamps
    end
  end
end
