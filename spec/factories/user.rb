FactoryBot.define do
  factory :admin, class: User do
    name "gloadmin"
    email "gloadmin@localhost.org"
    password "password"
    created_at Time.now.ago(10)
  end
  factory :user_assignment do
    role 'admin'
    cascades true
  end
end