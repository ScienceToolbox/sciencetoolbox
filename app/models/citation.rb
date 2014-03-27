class Citation < ActiveRecord::Base
  belongs_to :tool
  validates_uniqueness_of :doi, scope: :tool_id
end
