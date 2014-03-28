class Citation < ActiveRecord::Base
  belongs_to :tool
  validates_uniqueness_of :doi, scope: :tool_id
  validates_presence_of :doi
  validates_presence_of :tool_id
end
