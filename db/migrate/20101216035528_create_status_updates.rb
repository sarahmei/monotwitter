class CreateStatusUpdates < ActiveRecord::Migration
  def self.up
    create_table :status_updates do |t|
      t.text :text
      t.string :twitter_guid
      t.string :twitter_name
      t.string :image_url
      t.string :language_code
      t.datetime :post_date

      t.timestamps
    end
  end

  def self.down
    drop_table :status_updates
  end
end
