class ToolSerializer < ActiveModel::Serializer
  attributes :id, :url, :name, :created_at, :update_at, :description, :doi,
    :metadata, :test, :virtualization, :license, :readme, :ci,
    :reproducibility_score

  has_many :citations
end
