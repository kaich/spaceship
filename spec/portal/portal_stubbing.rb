require 'webmock/rspec'

def adp_read_fixture_file(filename)
  File.read(File.join('spec', 'portal', 'fixtures', filename))
end

# Optional: enterprise
def adp_enterprise_stubbing
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
    with(body: { "pageNumber" => "1", "pageSize" => "500", "sort" => "certRequestStatusCode=asc", "teamId" => "XXXXXXXXXX", "types" => "9RQEK7MSXA" }).
    to_return(status: 200, body: adp_read_fixture_file(File.join("enterprise", "listCertRequests.action.json")), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/createProvisioningProfile.action").
    with(body: { "appIdId" => "2UMR2S6PAA", "certificateIds" => "Q82WC5JRE9", "distributionType" => "inhouse", "provisioningProfileName" => "Delete Me", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('create_profile_success.json'), headers: { 'Content-Type' => 'application/json' })
end

# Optional: Team Selection
def adp_stub_multiple_teams
  stub_request(:post, 'https://developerservices2.apple.com/services/QH65B2/listTeams.action').
    to_return(status: 200, body: adp_read_fixture_file('listTeams_multiple.action.json'), headers: { 'Content-Type' => 'application/json' })
end

# Let the stubbing begin
def adp_stub_login
  stub_request(:get, "https://developer.apple.com/membercenter/index.action").
    to_return(status: 200, body: nil,
    headers: { 'Location' => "https://idmsa.apple.com/IDMSWebAuth/login?&appIdKey=aaabd3417a7776362562d2197faaa80a8aaab108fd934911bcbea0110d07faaa&path=%2F%2Fmembercenter%2Findex.action" })

  stub_request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate").
    with(body: { "accountPassword" => "so_secret", "appIdKey" => "aaabd3417a7776362562d2197faaa80a8aaab108fd934911bcbea0110d07faaa", "appleId" => "spaceship@krausefx.com" }).
    to_return(status: 302, body: "", headers: { 'Set-Cookie' => "myacinfo=abcdef;" })

  stub_request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate").
    with(body: { "accountPassword" => "bad-password", "appIdKey" => "aaabd3417a7776362562d2197faaa80a8aaab108fd934911bcbea0110d07faaa", "appleId" => "bad-username" }).
    to_return(status: 200, body: "Your Apple ID or password was entered incorrectly", headers: {})

  stub_request(:post, 'https://developerservices2.apple.com/services/QH65B2/listTeams.action').
    to_return(status: 200, body: adp_read_fixture_file('listTeams.action.json'), headers: { 'Content-Type' => 'application/json' })
end

def adp_stub_provisioning
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/listProvisioningProfiles.action").
    with(body: { "includeInactiveProfiles" => "true", "onlyCountLists" => "true", "pageNumber" => "1", "pageSize" => "500", "search" => "", "sort" => "name=asc", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('listProvisioningProfiles.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developerservices2.apple.com/services/QH65B2/ios/listProvisioningProfiles.action?includeInactiveProfiles=true&onlyCountLists=true&teamId=XXXXXXXXXX").
    to_return(status: 200, body: adp_read_fixture_file('listProvisioningProfiles.action.plist'), headers: { 'Content-Type' => 'application/x-xml-plist' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/getProvisioningProfile.action").
    to_return(status: 200, body: adp_read_fixture_file('getProvisioningProfile.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:get, "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=2MAY7NPHRU&teamId=XXXXXXXXXX").
    to_return(status: 200, body: adp_read_fixture_file("downloaded_provisioning_profile.mobileprovision"), headers: {})

  # Create Profiles

  # Name is free
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/createProvisioningProfile.action").
    with(body: { "appIdId" => "R9YNDTPLJX", "certificateIds" => "C8DL7464RQ", "deviceIds" => "C8DLAAAARQ", "distributionType" => "limited", "provisioningProfileName" => "net.sunapps.106 limited", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('create_profile_success.json'), headers: { 'Content-Type' => 'application/json' })

  # Name already taken
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/createProvisioningProfile.action").
    with(body: { "appIdId" => "R9YNDTPLJX", "certificateIds" => "C8DL7464RQ", "deviceIds" => "C8DLAAAARQ", "distributionType" => "limited", "provisioningProfileName" => "taken", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file("create_profile_name_taken.txt"))

  # Repair Profiles
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/regenProvisioningProfile.action").
    with(body: { "appIdId" => "572XTN75U2", "certificateIds" => "XC5PH8D47H", "deviceIds" => ["AAAAAAAAAA", "BBBBBBBBBB", "CCCCCCCCCC", "DDDDDDDDDD"], "distributionType" => "store", "provisioningProfileName" => "net.sunapps.7 AppStore", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('repair_profile_success.json'), headers: { 'Content-Type' => 'application/json' })

  # Delete Profiles
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/profile/deleteProvisioningProfile.action").
    with(body: { "provisioningProfileId" => "2MAY7NPHRU", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('deleteProvisioningProfile.action.json'), headers: { 'Content-Type' => 'application/json' })
end

def adp_stub_devices
  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
    with(body: { deviceClasses: 'iphone', teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listDevicesiPhone.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
    with(body: { deviceClasses: 'ipod', teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listDevicesiPod.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
    with(body: { deviceClasses: 'tvOS', teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listDevicesTV.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
    with(body: { deviceClasses: 'watch', teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listDevicesWatch.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
    with(body: { deviceClasses: 'tvOS', teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listDevicesTV.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
    with(body: { deviceClasses: 'watch', teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listDevicesWatch.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
    with(body: { teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listDevices.action.json'), headers: { 'Content-Type' => 'application/json' })

  # Register a new device
  stub_request(:post, "https://developerservices2.apple.com/services/QH65B2/ios/addDevice.action?deviceNumber=7f6c8dc83d77134b5a3a1c53f1202b395b04482b&name=Demo%20Device&teamId=XXXXXXXXXX").
    to_return(status: 200, body: adp_read_fixture_file('addDeviceResponse.action.plist'), headers: { 'Content-Type' => 'application/x-xml-plist' })

  # Custom paging
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action").
    with(body: { "pageNumber" => "1", "pageSize" => "8", "sort" => "name=asc", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('listDevicesPage1-2.action.json'), headers: { 'Content-Type' => 'application/json' })
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action").
    with(body: { "pageNumber" => "2", "pageSize" => "8", "sort" => "name=asc", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('listDevicesPage2-2.action.json'), headers: { 'Content-Type' => 'application/json' })
end

def adp_stub_certificates
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
    with(body: { "pageNumber" => "1", "pageSize" => "500", "sort" => "certRequestStatusCode=asc", "teamId" => "XXXXXXXXXX", "types" => "5QPB9NHCEI,R58UK2EWSO,9RQEK7MSXA,LA30L5BJEU,BKLRAVXMGM,UPV3DW712I,Y3B2F3TYSI,3T2ZP62QW8,E5D663CMZW,4APLUP237T,T44PTHVNID,DZQUP8189Y,FGQUP4785Z,S5WE21TULA,3BQKVH9I2X,FUOY7LWJET" }).
    to_return(status: 200, body: adp_read_fixture_file('listCertRequests.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
    with(body: { "pageNumber" => "1", "pageSize" => "500", "sort" => "certRequestStatusCode=asc", 'teamId' => 'XXXXXXXXXX', 'types' => '5QPB9NHCEI' }).
    to_return(status: 200, body: adp_read_fixture_file("list_certificates_filtered.json"), headers: { 'Content-Type' => 'application/json' })

  # When looking for distribution or development certificates only:
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
    with(body: { "pageNumber" => "1", "pageSize" => "500", "sort" => "certRequestStatusCode=asc", 'teamId' => 'XXXXXXXXXX', 'types' => 'R58UK2EWSO' }).
    to_return(status: 200, body: adp_read_fixture_file("list_certificates_filtered.json"), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/account/ios/certificate/certificateContentDownload.action").
    with(body: { "displayId" => "XC5PH8DAAA", "type" => "R58UK2EAAA", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('aps_development.cer'))
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/submitCertificateRequest.action").
    with(body: { "appIdId" => "2HNR359G63", "csrContent" => adp_read_fixture_file('certificateSigningRequest.certSigningRequest'), "type" => "BKLRAVXMGM", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('submitCertificateRequest.action.json'), headers: { 'Content-Type' => 'application/json' })
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/revokeCertificate.action").
    with(body: { "certificateId" => "XC5PH8DAAA", "teamId" => "XXXXXXXXXX", "type" => "R58UK2EAAA" }).
    to_return(status: 200, body: adp_read_fixture_file('revokeCertificate.action.json'), headers: { 'Content-Type' => 'application/json' })
end

def adp_stub_apps
  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/listAppIds.action').
    with(body: { teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listApps.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/getAppIdDetail.action").
    with(body: { appIdId: "B7JBD8LHAA", teamId: "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('getAppIdDetail.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/addAppId.action").
    with(body: { "appIdName" => "Production App", "appIdentifierString" => "tools.fastlane.spaceship.some-explicit-app", "explicitIdentifier" => "tools.fastlane.spaceship.some-explicit-app", "gameCenter" => "on", "inAppPurchase" => "on", "push" => "on", "teamId" => "XXXXXXXXXX", "type" => "explicit" }).
    to_return(status: 200, body: adp_read_fixture_file('addAppId.action.explicit.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/addAppId.action").
    with(body: { "appIdName" => "Development App", "appIdentifierString" => "tools.fastlane.spaceship.*", "teamId" => "XXXXXXXXXX", "type" => "wildcard", "wildcardIdentifier" => "tools.fastlane.spaceship.*" }).
    to_return(status: 200, body: adp_read_fixture_file('addAppId.action.wildcard.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/deleteAppId.action").
    with(body: { "appIdId" => "LXD24VUE49", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('deleteAppId.action.json'), headers: { 'Content-Type' => 'application/json' })
end

def adp_stub_app_groups
  stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/listApplicationGroups.action').
    with(body: { teamId: 'XXXXXXXXXX', pageSize: "500", pageNumber: "1", sort: 'name=asc' }).
    to_return(status: 200, body: adp_read_fixture_file('listApplicationGroups.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/addApplicationGroup.action").
    with(body: { "name" => "Production App Group", "identifier" => "group.tools.fastlane.spaceship", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('addApplicationGroup.action.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/deleteApplicationGroup.action").
    with(body: { "applicationGroup" => "2GKKV64NUG", "teamId" => "XXXXXXXXXX" }).
    to_return(status: 200, body: adp_read_fixture_file('deleteApplicationGroup.action.json'), headers: { 'Content-Type' => 'application/json' })
end

def adp_stub_download_certificate_failure
  stub_request(:post, 'https://developer.apple.com/account/ios/certificate/certificateContentDownload.action').
    to_return(status: 404, body: adp_read_fixture_file('download_certificate_failure.html'))
end

def adp_stub_download_provisioning_profile_failure
  stub_request(:get, "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=2MAY7NPHRU&teamId=XXXXXXXXXX").
    to_return(status: 404, body: adp_read_fixture_file('download_certificate_failure.html'))
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    adp_stub_login
    adp_stub_provisioning
    adp_stub_devices
    adp_stub_certificates
    adp_stub_apps
    adp_stub_app_groups
  end
end
