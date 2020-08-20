class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :login
      t.string :language
      t.integer :number_repos
      t.timestamps
    end
  end
end
