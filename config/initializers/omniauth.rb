Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer
  provider :facebook, "foo", "bar"
end