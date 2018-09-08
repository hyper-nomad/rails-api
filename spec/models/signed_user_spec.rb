require 'rails_helper'

RSpec.describe SignedUser, :type => :model do
  describe '::ipass_authenticate' do
    subject{ SignedUser.ipass_authenticate email, password }
    let(:valid_user){ SignedUser.find_by_email 'user1@example.com' }

    context 'GOOD email & password' do
      let(:email){ 'user1@example.com' }
      let(:password){ 'test1234' }

      it{ should == valid_user }
    end

    context 'GOOD email & BAD password' do
      let(:email){ 'user1@example.com' }
      let(:password){ 'test1233' }

      it{ should be_nil }
    end

    context 'BAD email' do
      let(:email){ 'user0@example.com' }
      let(:password){ 'test1234' }

      it{ should be_nil }
    end
  end
  describe '#uniqueness_of_naked_email' do
    pending
  end
  describe '#save_naked_email' do
    pending
  end
end
