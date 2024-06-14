require 'active_support/concern'
require 'devise/rownd/log'

module Devise
  module Models
    module RowndAuthenticatable
      extend ActiveSupport::Concern

      # TODO: What if we don't interact with the database at all?
      class_methods do
        def find_or_create_with_authentication_profile(profile)
          where(user_id: profile['user_id']).first_or_create({ email: profile['email'] })
        end

        def serialize_from_session(access_token)
          Devise::Rownd::Log.debug("serialize_from_session: #{access_token}")
          return nil if access_token.nil?

          begin
            data = Devise::Rownd::User.fetch_user(access_token)
          rescue StandardError => e
            Devise::Rownd::Log.debug("serialize_from_session: session has invalid access token #{e.message}")
            return nil
          end

          if data.nil?
            Devise::Rownd::Log.debug('serialize_from_session: could not fetch user profile')
            return nil
          end

          # initialize user with fetched data
          user = Devise::Rownd::User.new(data, access_token)
          Devise::Rownd::Log.debug("serialize_from_session result: #{user}")
          user
        end

        def serialize_into_session(record)
          Devise::Rownd::Log.debug("serialize_into_session: #{record}")

          record.access_token
        end

        # def find_by_user_id_or_email(user_id, email)
        #   result = find_by('user_id = ? OR email = ?', user_id, email)
        #   result
        # end
      end
    end
  end
end
