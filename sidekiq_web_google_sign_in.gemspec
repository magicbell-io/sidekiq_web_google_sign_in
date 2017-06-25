Gem::Specification.new do |s|
  s.name        = 'sidekiq_web_google_sign_in'
  s.version     = '1.0.0.beta1' # See http://guides.rubygems.org/patterns/#prerelease-gems
  s.date        = '2017-06-24'
  s.summary     = "Restrict access to your Sidekiq using Google Sign In"
  s.description = "Restrict access to your Sidekiq using Google Sign In"
  s.authors     = ["Nisanth Chunduru"]
  s.email       = "nisanth074@gmail.com"
  s.files       = ["lib/sidekiq_web_google_sign_in.rb"]
  s.homepage    = "https://github.com/magicbell-io/sidekiq_web_google_sign_in"

  s.add_dependency("omniauth-google-oauth2")
end
