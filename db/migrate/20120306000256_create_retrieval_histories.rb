class CreateRetrievalHistories < ActiveRecord::Migration
  def change
    create_table :retrieval_histories do |t|
      t.integer  :article_id, :null => false   # article id (from articles table)
      t.integer  :source_id, :null => false    # source id (from sources table)
      t.datetime :retrieved_at                 # when data was retrieved for the given article for the given source
      t.string   :status                       # status of the retrieval (success or failure)
      t.string   :msg                          # extra information about the status of the retrieval
      t.integer  :event_count                  # event count

      t.timestamps
    end
  end
end
