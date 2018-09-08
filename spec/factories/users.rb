FactoryGirl.define do
  factory :signed_user do
    sequence(:email){|i| "user#{i+3}@example.com"}
    password 'test1234'
  end
  factory :user do
    sequence(:email){|i| "user#{i+3}@example.com"}
    password 'test1234'
    before :create do |user|
      user.password_confirmation = user.password
      user.skip_confirmation!
    end
    # factory :user_with_first_book do
      # after :create do |user|
        # coupon_book = build(:first_coupon_book)
        # coupon_book.reflect! user
        # coupon_book.save
      # end
    # end
    # factory :trial_user do
      # after :create do |user|
        # coupon_book = build(:trial_coupon_book)
        # coupon_book.reflect! user
        # coupon_book.save
      # end
    # end
    # factory :subscription_user do
      # after :create do |user|
        # purchase = user.pre_buy! build(:subscription_coupon_book)
        # purchase.mark_pay!
      # end
    # end
  end
end
