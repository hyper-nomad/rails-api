require 'rails_helper'

RSpec.describe NakedEmail, :type => :model do
  describe '#naked_before_hashed' do
    subject{ emails.map{|email| NakedEmail.new(email).naked_before_hashed } }

    shared_examples_for 'should match naked email before hashed' do
      it do
        is_expected.to eq results
      end
    end

    context 'No gmail domain' do
      let(:emails) do
        %w(
          test@example.com
          .te.st.+alias@gmo-k.jp
        )
      end
      let(:results) do
        %w(
          test@example.com
          .te.st.+alias@gmo-k.jp
        )
      end
      it_behaves_like 'should match naked email before hashed'
    end
    context 'Gmail domain' do
      let(:emails){ %w(test@gmail.com) }
      let(:results){ %w(test@gmail.com) }
      it_behaves_like 'should match naked email before hashed'

      context 'plus alias' do
        let(:emails) do
          %w(
            test+@gmail.com
            test+a@gmail.com
            test+a.b.c@gmail.com
          )
        end
        let(:results) do
          %w(
            test@gmail.com
            test@gmail.com
            test@gmail.com
          )
        end
        it_behaves_like 'should match naked email before hashed'
      end
      context 'period alias' do
        let(:emails) do
          %w(
            .test@gmail.com
            test.@gmail.com
            te.st@gmail.com
            ..t.e.st...@gmail.com
          )
        end
        let(:results) do
          %w(
            test@gmail.com
            test@gmail.com
            test@gmail.com
            test@gmail.com
          )
        end
        it_behaves_like 'should match naked email before hashed'
      end
      context 'domain alias' do
        let(:emails) do
          %w(
            test@gmail.com
            test@googlemail.com
            test@agmail.com
            test@googlemail.coma
          )
        end
        let(:results) do
          %w(
            test@gmail.com
            test@gmail.com
            test@agmail.com
            test@googlemail.coma
          )
        end
        it_behaves_like 'should match naked email before hashed'
      end
      context 'mixed alias' do
        let(:emails) do
          %w(
            ..te.st..+alias@googlemail.com
          )
        end
        let(:results) do
          %w(
            test@gmail.com
          )
        end
        it_behaves_like 'should match naked email before hashed'
      end
    end
  end

  def hexdigest str
    Digest::SHA256.hexdigest(str)
  end
end
