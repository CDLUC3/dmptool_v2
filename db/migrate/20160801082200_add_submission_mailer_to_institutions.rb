class AddSubmissionMailerToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :submission_mailer_subject, :string
    add_column :institutions, :submission_mailer_body, :text
  end
end
