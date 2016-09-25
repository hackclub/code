FactoryGirl.define do
  factory :streak_pipeline, class: 'Streak::Pipeline' do
    streak_key { Faker::Lorem.characters(32) }
    name { Faker::Lorem.words(4).join(" ").titlecase }
  end
end