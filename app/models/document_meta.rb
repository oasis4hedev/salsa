class DocumentMeta < ApplicationRecord
  validates_presence_of :key
  validates_presence_of :value
  validates_presence_of :lms_organization_id, :lms_course_id, :root_organization_id

  belongs_to :document, optional: true
end
