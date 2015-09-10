class ChangeInstitutionColumnNameToInstitutionCode < ActiveRecord::Migration
  def change
    rename_column :users, :institution, :institution_code
  end
end
