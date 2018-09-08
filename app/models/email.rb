class Email < ActiveRecord::Base
  def self.include? naked_email
    where(naked: naked_email.naked).count >= 1
  end

  def self.create_naked! naked_email
    create!(naked: naked_email.naked)
  end
end
