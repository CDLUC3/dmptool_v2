class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :full_name
      t.string :nickname
      t.text :desc
      t.string :contact_info
      t.string :contact_email
      t.string :url
      t.string :url_text
      t.string :shib_entity_id
      t.string :shib_domain

      t.timestamps
    end
  end
end
