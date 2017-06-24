class SidekiqWebGoogleSignIn
  class << self
    def use(options)
      @options = options

      google_sign_in_client_id, google_sign_in_client_secret = @options.values_at(:google_sign_in_client_id, :google_sign_in_client_secret)
      Sidekiq::Web.use OmniAuth::Builder do
        provider :google_oauth2, google_sign_in_client_id, google_sign_in_client_secret
      end
      sidekiq_web_session_options = {
        :key => "_sidekiqweb_session",
        :domain => @options[:session_domain],
        :path => "/sidekiq",
        :expire_after => 24 * 60 * 60, # Automatically expire session after 24 hours
        :secret => session_secret
      }
      Sidekiq::Web.set :sessions, sidekiq_web_session_options
      Sidekiq::Web.register(SidekiqWebGoogleSignIn)
    end

    def registered(sidekiq_web)
      sidekiq_web.before do
        next if signing_in? or signed_in?

        if html_request?
          redirect_to_google_sign_in_page
        else
          halt(403)
        end
      end

      sidekiq_web.get "/auth/google_oauth2/callback" do
        if employee?
          sign_in
          redirect_to_sidekiq_dashboard
        else
          halt(403)
        end
      end

      sidekiq_web.helpers do
        def signed_in?
          session[:signed_in]
        end

        def signing_in?
          request.path_info.start_with?("/auth/google_oauth2")
        end

        def html_request?
          request.env["HTTP_ACCEPT"].include?("text/html")
        end

        def redirect_to_google_sign_in_page
          redirect "/sidekiq/auth/google_oauth2"
        end

        def employee?
          is_employee_email?(request.env["omniauth.auth"]["info"]["email"])
        end

        def is_employee_email?(email)
          @options[:employee_emails].call(email)
        end

        def redirect_to_sidekiq_dashboard
          redirect "/sidekiq"
        end

        def sign_in
          session[:signed_in] = true
        end
      end
    end

    private

    def session_secret
      # Rails < 4
      if Rails.configuration.respond_to?(:secret_token)
        Rails.configuration.secret_token
      # Rails >= 4
      else
        Rails.application.secrets[:secret_key_base]
      end
    end
  end
end
