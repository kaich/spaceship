Developer Portal API
====================

# Usage

To quickly play around with `spaceship` launch `irb` in your terminal and execute `require "spaceship"`. 

## Login

*Note*: If you use both the Developer Portal and iTunes Connect API, you'll have to login on both, as the user might have different user credentials.

```ruby
Spaceship.login("felix@krausefx.com", "password")

Spaceship.select_team # call this method to let the user select a team
```

## Apps

```ruby
# Fetch all available apps
all_apps = Spaceship.app.all

# Find a specific app based on the bundle identifier
app = Spaceship.app.find("com.krausefx.app")

# Show the names of all your apps
Spaceship.app.all.collect do |app|
  app.name
end

# Create a new app
app = Spaceship.app.create!(bundle_id: "com.krausefx.app_name", name: "fastlane App")
```

### App Services

App Services are part of the application, however, they are one of the few things that can be changed about the app once it has been created.

Currently available services include (all require the `Spaceship.app_service.` prefix)

```
app_group.(on|off)
associated_domains.(on|off)
data_protection.(complete|unless_open|until_first_auth|off)
health_kit.(on|off)
home_kit.(on|off)
wireless_accessory.(on|off)
icloud.(on|off)
cloud_kit.(xcode5_compatible|cloud_kit)
inter_app_audio.(on|off)
passbook.(on|off)
push_notification.(on|off)
vpn_configuration.(on|off)
```

Examples:

```ruby
# Find a specific app based on the bundle identifier
app = Spaceship.app.find("com.krausefx.app")

# Enable HealthKit, but make sure HomeKit is disabled
app.update_service(Spaceship.app_service.health_kit.on)
app.update_service(Spaceship.app_service.home_kit.off)
app.update_service(Spaceship.app_service.vpn_configuration.on)
app.update_service(Spaceship.app_service.passbook.off)
app.update_service(Spaceship.app_service.cloud_kit.cloud_kit)
```

## App Groups

```ruby
# Fetch all existing app groups
all_groups = Spaceship.app_group.all

# Find a specific app group, based on the identifier
group = Spaceship.app_group.find("group.com.example.application")

# Show the names of all the groups
Spaceship.app_group.all.collect do |group|
  group.name
end

# Create a new group
group = Spaceship.app_group.create!(group_id: "group.com.example.another", 
                                        name: "Another group")

# Associate an app with this group (overwrites any previous associations)
# Assumes app contains a fetched app, as described above
app = app.associate_groups([group])
```

## Certificates

```ruby
# Fetch all available certificates (includes signing and push profiles)
certificates = Spaceship.certificate.all
```

### Code Signing Certificates

```ruby
# Production identities
prod_certs = Spaceship.certificate.production.all

# Development identities
dev_certs = Spaceship.certificate.development.all

# Download a certificate
cert_content = prod_certs.first.download
```

### Push Certificates
```ruby
# Production push profiles
prod_push_certs = Spaceship.certificate.production_push.all

# Development push profiles
dev_push_certs = Spaceship.certificate.development_push.all

# Download a push profile
cert_content = dev_push_certs.first.download
```

### Create a Certificate

```ruby
# Create a new certificate signing request
csr, pkey = Spaceship.certificate.create_certificate_signing_request

# Use the signing request to create a new distribution certificate
Spaceship.certificate.production.create!(csr: csr)

# Use the signing request to create a new push certificate
Spaceship.certificate.production_push.create!(csr: csr, bundle_id: "com.krausefx.app")
```

## Provisioning Profiles

### Receiving profiles

```ruby
##### Finding #####

# Get all available provisioning profiles
profiles = Spaceship.provisioning_profile.all

# Get all App Store profiles
profiles_appstore = Spaceship.provisioning_profile.app_store.all

# Get all AdHoc profiles
profiles_adhoc = Spaceship.provisioning_profile.ad_hoc.all

# Get all Development profiles
profiles_dev = Spaceship.provisioning_profile.development.all

# Fetch all profiles for a specific app identifier for the App Store
filtered_profiles = Spaceship.provisioning_profile.app_store.find_by_bundle_id("com.krausefx.app")

##### Downloading #####

# Download a profile
profile_content = profiles.first.download

# Download a specific profile as file
my_profile = Spaceship.provisioning_profile.app_store.find_by_bundle_id("com.krausefx.app")
File.write("output.mobileprovision", my_profile.download)
```

### Create a Provisioning Profile

```ruby
# Choose the certificate to use
cert = Spaceship.certificate.production.all.first

# Create a new provisioning profile with a default name
# The name of the new profile is "com.krausefx.app AppStore"
profile = Spaceship.provisioning_profile.app_store.create!(bundle_id: "com.krausefx.app",
                                                         certificate: cert)

# AdHoc Profiles will add all devices by default
profile = Spaceship.provisioning_profile.ad_hoc.create!(bundle_id: "com.krausefx.app",
                                                      certificate: cert,
                                                             name: "Profile Name")

# Store the new profile on the filesystem
File.write("NewProfile.mobileprovision", profile.download)
```

### Repair all broken provisioning profiles

```ruby
# Select all 'Invalid' or 'Expired' provisioning profiles
broken_profiles = Spaceship.provisioning_profile.all.find_all do |profile| 
  # the below could be replaced with `!profile.valid?`, which takes longer but also verifies the code signing identity
  (profile.status == "Invalid" or profile.status == "Expired") 
end

# Iterate over all broken profiles and repair them
broken_profiles.each do |profile|
  profile.repair! # yes, that's all you need to repair a profile
end

# or to do the same thing, just more Ruby like
Spaceship.provisioning_profile.all.find_all { |p| !p.valid? }.map(&:repair!)
```

## Devices

```ruby
all_devices = Spaceship.device.all

# Register a new device
Spaceship.device.create!(name: "Private iPhone 6", udid: "5814abb3...")
```

## Enterprise

```ruby
# Use the InHouse class to get all enterprise certificates
cert = Spaceship.certificate.in_house.all.first 

# Create a new InHouse Enterprise distribution profile
profile = Spaceship.provisioning_profile.in_house.create!(bundle_id: "com.krausefx.*",
                                                        certificate: cert)

# List all In-House Provisioning Profiles
profiles = Spaceship.provisioning_profile.in_house.all
```

## Multiple Spaceships

Sometimes one `spaceship` just isn't enough. That's why this library has its own Spaceship Launcher to launch and use multiple `spaceships` at the same time :rocket:

```ruby
# Launch 2 spaceships
spaceship1 = Spaceship::Launcher.new("felix@krausefx.com", "password")
spaceship2 = Spaceship::Launcher.new("stefan@spaceship.airforce", "password")

# Fetch all registered devices from spaceship1
devices = spaceship1.device.all

# Iterate over the list of available devices
# and register each device from the first account also on the second one
devices.each do |device|
  spaceship2.device.create!(name: device.name, udid: device.udid)
end
```

## More cool things you can do
```ruby
# Find a profile with a specific name
profile = Spaceship.provisioning_profile.development.all.find { |p| p.name == "Name" }

# Add all available devices to the profile
profile.devices = Spaceship.device.all

# Push the changes back to the Apple Developer Portal
profile.update!

# Get the currently used team_id
Spaceship.client.team_id

# We generally don't want to be destructive, but you can also delete things
# This method might fail for various reasons, e.g. app is already in the store
app = Spaceship.app.find("com.krausefx.app")
app.delete!
```

## Example Data

Some unnecessary information was removed, check out [provisioning_profile.rb](https://github.com/fastlane/spaceship/blob/master/lib/spaceship/portal/provisioning_profile.rb) for all available attributes.

The example data below is a provisioning profile, containing a device, certificate and app. 

```
#<Spaceship::ProvisioningProfile::AdHoc 
  @devices=[
    #<Spaceship::Device 
      @id="5YTNZ5A9AA", 
      @name="Felix iPhone 6", 
      @udid="39d2cab02642dc2bfdbbff4c0cb0e50c8632faaa"
    >,  ...], 
  @certificates=[
    #<Spaceship::Certificate::Production 
      @id="LHNT9C2AAA", 
      @name="iOS Distribution", 
      @expires=#<DateTime: 2016-02-10T23:44:20>
    ], 
  @id="72SRVUNAAA", 
  @uuid="43cda0d6-04a5-4964-89c0-a24b5f258aaa", 
  @expires=#<DateTime: 2016-02-10T23:44:20>, 
  @distribution_method="adhoc", 
  @name="com.krausefx.app AppStore", 
  @status="Active", 
  @platform="ios", 
  @app=#<Spaceship::App 
    @app_id="2UMR2S6AAA", 
    @name="App Name", 
    @platform="ios", 
    @bundle_id="com.krausefx.app", 
    @is_wildcard=false>
  >
>
```

### License

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
