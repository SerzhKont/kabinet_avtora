class RenameAuthorAccessTokensToDocumentGroups < ActiveRecord::Migration[8.1]
  def change
    rename_table :author_access_tokens, :document_groups
  end
end
