class Organization < ApplicationRecord
  before_destroy :allow_destroy
  # ^ this has to be above act_as_nested_set
  
  acts_as_nested_set

  has_many :documents
  has_many :components
  has_many :periods
  has_many :user_assignments
  has_many :users, through: :user_assignments
  has_many :workflow_steps
  has_many :report_archives

  before_validation :use_nil_for_blank_name_reports_by
  before_validation :use_nil_for_blank_time_zone

  SLUG_FORMAT = /(\/?([a-z0-9][a-z0-9.-]+)?[a-z0-9]+)/

  default_scope { order('lft, rgt') }
  validates :slug, presence: true, format: {with: Regexp.new('\A' + SLUG_FORMAT.source + '\z')}
  validates_uniqueness_of :slug, :scope => :parent_id
  validates :slug, exclusion: { in: %w(status), message: "%{value} is reserved." }
  validates_length_of :slug, minimum: 3, maximum: 128

  validates :name, presence: true

  def self.export_types
    ["default","Program Outcomes"]
  end
  validates :export_type, :inclusion=> { :in => self.export_types }
  
  def self.name_reports_by_options
    {
      # id: "document.id",
      # workflow_state: "report_data.workflow_state",
      name: "document.name",
      lms_course_id: "document.lms_course_id",
      sis_course_id: "document_meta.sis_course_id"
    }
  end
  validates :name_reports_by, :inclusion=> { :in => self.name_reports_by_options.values.push(nil) }

  def full_slug
    if self.slug.start_with?("/")
      slugs = self.parents.reverse.map(&:slug) + [self.slug.gsub(/\//,'')]
      return slugs.join('/').gsub(/\/\//,'/')
    else
      return self.slug
    end
  end

  def path
    if self.slug.start_with?("/")
      slugs = self.parents.reverse.map(&:slug) + [self.slug.gsub(/\//,'')]
      slugs[1..-1].join('/').gsub(/\/\//,'/').gsub(/^\//,'')
    end
  end

  def parents
    parents = []
    parent = self.parent
    while parent != nil do
      parents.push parent
      parent = parent.parent
    end
    return parents
  end

  def organization_ids
    org_ids = [self.id]
    if self.root_org_setting("inherit_workflows_from_parents")
      org_ids = self.parents.map{|x| x[:id]}
    end
    return org_ids
  end

  def full_org_path
    if self.depth > 0 and self.slug.start_with?('/')
      org_slug = self.self_and_ancestors.pluck(:slug).join ''
    else
      org_slug = self.slug
    end

    org_slug
  end
  
  def use_nil_for_blank_name_reports_by
    self.name_reports_by = nil if name_reports_by.blank?
  end

  def get_name_reports_by(subs = {})
    subs = subs.stringify_keys
    name_by = self.setting("name_reports_by")
    name_by = Organization.name_reports_by_options.values.first if name_by.blank?
    subs.each { |k, v| name_by["#{k.to_s}."] &&= "#{v.to_s}." }
    name_by
  end

  # force null save so setting can cascade up the tree (most settings should probably be this way)
  def lms_authentication_source=(val)
    super(val == "" ? nil : val)
  end

  def self_or_ancestors_setting(setting)
    self.self_and_ancestors.where.not( setting=>nil ).reorder(:depth).last&.read_attribute(setting)
  end

  def setting(setting)
    @settings ||= {}
    @settings[setting.to_s] ||= self_or_ancestors_setting setting
  end

  def root_org_setting(setting)
    @root_settings ||= {}
    @root_settings[setting.to_s] ||= self.root[setting]
  end

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
  
  def can_delete?
    self.descendants.blank?
  end
  
  def all_periods
    Period.where(organization_id: self.root.self_and_descendants)
  end

  def expire_lock
    self.republish_at = nil
    self.republish_batch_token = nil
    self.save!
  end

  private
  
  def use_nil_for_blank_time_zone
    self.time_zone = nil if time_zone.blank?
  end

  def allow_destroy
    return true if self.can_delete?
    self.errors.add('Cannot_delete', 'that organization has sub organizations')
    false
    throw(:abort)
  end

end
