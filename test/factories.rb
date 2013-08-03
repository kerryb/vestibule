FactoryGirl.define do
  factory :user do |f|
    f.signup_reason "I want to get involved with the content of the conference day"
    f.name { Faker::Name.name }
    f.sequence(:ein) { |n| "#{n}123456" }
    f.email { Faker::Internet.email }
  end

  factory :proposal do |f|
    f.sequence(:title) { |n| Faker::Lorem.sentence(3, true) + " #{n}" }
    f.association :proposer, :factory => :user
    f.withdrawn false
  end

  factory :suggestion do |f|
    f.association :proposal
    f.association :author, :factory => :user
    f.body { Faker::Lorem.paragraph(3, true) }
  end
end
