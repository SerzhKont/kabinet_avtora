class RemoveInvalidUploadedByForeignKeyFromDocuments < ActiveRecord::Migration[8.0]
  def up
    begin
      remove_foreign_key :documents, :uploaded_bies
    rescue ActiveRecord::StatementInvalid => e
      puts "Foreign key already removed or doesn't exist: #{e.message}"
    end
  end
end
