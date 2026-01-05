class CreateBookPosts < ActiveRecord::Migration[7.1]
  def change
    create_table :book_posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :author
      t.text :body

      t.timestamps
    end
  end
end
