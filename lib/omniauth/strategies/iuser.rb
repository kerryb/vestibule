module OmniAuth
  module Strategies
    class Iuser
      include OmniAuth::Strategy

      option :fields, [:ein, :name, :email]
      option :uid_field, :ein

      def request_phase
        form = OmniAuth::Form.new(title: "Login", url: callback_path)
        form.text_field "EIN", "ein"
        form.text_field "IUSER password", "password"
        form.button "Sign in"
        form.to_response
      end

      uid do
        request.params[options.uid_field.to_s]
      end

      info do
        {
          ein: request.params[:ein],
          name: "Fred Bloggs",
          email: "fred@example.com",
        }
      end
    end
  end
end
