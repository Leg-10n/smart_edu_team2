# # config/initializers/omise.rb
# require 'omise'
#
# if Rails.env.production?
#   Omise.api_key = Rails.application.credentials.dig(:omise, :secret_key)
#   Omise.public_api_key = Rails.application.credentials.dig(:omise, :public_key)
# else
#   # Using your test keys
#   Omise.api_key = 'skey_test_631ivir9myz0s778fk2'
#   Omise.public_api_key = 'pkey_test_631iviqr16qva0uvdrt'
# end

# config/initializers/omise.rb
require "omise"

# Just use the test keys directly for now
Omise.api_key = "skey_test_631ivir9myz0s778fk2"
Omise.public_api_key = "pkey_test_631iviqr16qva0uvdrt"
