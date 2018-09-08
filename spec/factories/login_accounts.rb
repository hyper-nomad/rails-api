FactoryGirl.define do
  factory :login_account do
    factory :redish_account do
      provider 'redish'
    end
    factory :facebook_account do
      provider 'facebook'
    end
  end
end
