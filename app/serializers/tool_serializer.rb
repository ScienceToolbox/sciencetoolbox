class ToolSerializer < ActiveModel::Serializer
  attributes :id, :url, :name, :created_at, :updated_at, :description, :doi,
    :metadata, :test, :virtualization, :license, :readme, :ci,
    :reproducibility_score, :citations_count

  has_many :citations, embed: :ids, include: true
  has_many :tags, embed: :ids, include: true
end
