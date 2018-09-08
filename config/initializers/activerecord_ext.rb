module ActiveRecord
  class Base
    def self.attr_name attr
      human_attribute_name attr
    end
  end
end
