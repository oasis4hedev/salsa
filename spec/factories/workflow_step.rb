require 'faker'

FactoryBot.define do
  factory :workflow_step do
    name Faker::Name.unique.name
    slug Faker::Types.unique.rb_string
    start_step false
    end_step false
    organization_id 1
  end
end
