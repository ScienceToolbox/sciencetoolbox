module ActsAsTaggableOn
  class TagSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
