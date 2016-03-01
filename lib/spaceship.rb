require 'spaceship/version'
require 'spaceship/base'
require 'spaceship/client'
require 'spaceship/launcher'

# Dev Portal
require 'spaceship/portal/portal'
require 'spaceship/portal/spaceship'


# To support legacy code
module Spaceship
  # Dev Portal
  Certificate = Spaceship::Portal::Certificate
  ProvisioningProfile = Spaceship::Portal::ProvisioningProfile
  Device = Spaceship::Portal::Device
end
