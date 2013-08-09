require "crowd"

module OmniAuth
  module Strategies
    class Iuser
      include OmniAuth::Strategy

      option :fields, [:ein, :name, :email]
      option :uid_field, :ein

      def request_phase
        form = OmniAuth::Form.new(title: "Login", url: callback_path)
        form.text_field "EIN", "ein"
        form.password_field "IUSER password", "password"
        form.button "Sign in"
        form.to_response
      end

      def callback_phase
        crowd = Crowd.new(crowd_uri: Rails.configuration.crowd_uri,
                          application_name: Rails.configuration.crowd_application_name,
                          application_password: Rails.configuration.crowd_application_password)
        begin
          @user_details = crowd.authenticate(request.params[:ein], request.params[:password])
          super
        rescue => e
          Rails.logger.warn e.inspect
          e.backtrace.each {|l| Rails.logger.warn l }
          fail! :invalid_credentials
        end
      end

      uid do
        request.params[options.uid_field.to_s]
      end

      info do
        {
          ein: uid,
          name: @user_details[:name],
          email: @user_details[:email],
        }
      end
    end
  end
end
