class ChangeInstitutionLogoToBinary < ActiveRecord::Migration

	def up
	  change_column :institutions, :logo, :binary
	end

	def down
	  change_column :institutions, :logo, :string
	end

end
