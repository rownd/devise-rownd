module Devise
  module Rownd
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
