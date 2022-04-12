require 'active_support/concern'

module Devise
  module Models
    module RowndAuthenticatable
      extend ActiveSupport::Concern

      class_methods do
        def find_or_create_with_authentication_profile(profile)
          result = where(user_id: profile['user_id']).first_or_create({ email: profile['email'] })
          result
        end

        def serialize_from_session(user_id, email)
          result = find_by_user_id_or_email(user_id, email)
          result
        end

        def serialize_into_session(resource)
          result = [resource['user_id'], resource['email']]
          result
        end

        def find_by_user_id_or_email(user_id, email)
          result = find_by('user_id = ? OR email = ?', user_id, email)
          result
        end
      end
    end
  end
end
