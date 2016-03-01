require 'webmock/rspec'

def itc_read_fixture_file(filename)
  File.read(File.join('spec', 'tunes', 'fixtures', filename))
end

def itc_stub_login
  # Retrieving the current login URL

  stub_request(:get, 'https://itunesconnect.apple.com/itc/static-resources/controllers/login_cntrl.js').
    to_return(status: 200, body: itc_read_fixture_file('login_cntrl.js'))
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa").
    to_return(status: 200, body: "")
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wa/route?noext=true").
    to_return(status: 200, body: "")

  # Actual login
  stub_request(:post, "https://idmsa.apple.com/appleauth/auth/signin?widgetKey=1234567890").
    with(body: { "accountName" => "spaceship@krausefx.com", "password" => "so_secret", "rememberMe" => true }.to_json).
    to_return(status: 200, body: '{}')

  # Failed login attempts
  stub_request(:post, "https://idmsa.apple.com/appleauth/auth/signin?widgetKey=1234567890").
    with(body: { "accountName" => "bad-username", "password" => "bad-password", "rememberMe" => true }.to_json).
    to_return(status: 401, body: '{}', headers: { 'Set-Cookie' => 'session=invalid' })
end

def itc_stub_applications
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/manageyourapps/summary/v2").
    to_return(status: 200, body: itc_read_fixture_file('app_summary.json'), headers: { 'Content-Type' => 'application/json' })

  # Create Version stubbing
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/create/1013943394").
    with(body: "{\"version\":\"0.1\"}").
    to_return(status: 200, body: itc_read_fixture_file('create_version_success.json'), headers: { 'Content-Type' => 'application/json' })

  # Create Application
  # Pre-Fill request
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2/?platformString=ios").
    to_return(status: 200, body: itc_read_fixture_file('create_application_prefill_request.json'), headers: { 'Content-Type' => 'application/json' })

  # Actual sucess request
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2").
    to_return(status: 200, body: itc_read_fixture_file('create_application_success.json'), headers: { 'Content-Type' => 'application/json' })

  # Overview of application to get the versions
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1013943394/overview").
    to_return(status: 200, body: itc_read_fixture_file('app_overview.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/overview").
    to_return(status: 200, body: itc_read_fixture_file('app_overview.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1000000000/overview").
    to_return(status: 200, body: itc_read_fixture_file('app_overview_stuckinprepare.json'), headers: { 'Content-Type' => 'application/json' })

  # App Details
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/details").
    to_return(status: 200, body: itc_read_fixture_file('app_details.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_candiate_builds
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/candidateBuilds").
    to_return(status: 200, body: itc_read_fixture_file('candiate_builds.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_applications_first_create
  # Create First Application
  # Pre-Fill request
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2/?platformString=ios").
    to_return(status: 200, body: itc_read_fixture_file('create_application_prefill_first_request.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_applications_broken_first_create
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2").
    to_return(status: 200, body: itc_read_fixture_file('create_application_first_broken.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_broken_create
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2").
    to_return(status: 200, body: itc_read_fixture_file('create_application_broken.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_broken_create_wildcard
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2").
    to_return(status: 200, body: itc_read_fixture_file('create_application_wildcard_broken.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_app_versions
  # Receiving app version
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/813314674").
    to_return(status: 200, body: itc_read_fixture_file('app_version.json'), headers: { 'Content-Type' => 'application/json' })
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/113314675").
    to_return(status: 200, body: itc_read_fixture_file('app_version.json'), headers: { 'Content-Type' => 'application/json' })
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1000000000/platforms/ios/versions/800000000").
    to_return(status: 200, body: itc_read_fixture_file('app_version.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_app_submissions
  # Start app submission
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/submit/summary").
    to_return(status: 200, body: itc_read_fixture_file('app_submission/start_success.json'), headers: { 'Content-Type' => 'application/json' })

  # Complete app submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/complete").
    to_return(status: 200, body: itc_read_fixture_file('app_submission/complete_success.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_app_submissions_already_submitted
  # Start app submission
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/submit/summary").
    to_return(status: 200, body: itc_read_fixture_file('app_submission/start_success.json'), headers: { 'Content-Type' => 'application/json' })

  # Complete app submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/complete").
    to_return(status: 200, body: itc_read_fixture_file('app_submission/complete_failed.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_app_submissions_invalid
  # Start app submission
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/submit/summary").
    to_return(status: 200, body: itc_read_fixture_file('app_submission/start_failed.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_resolution_center
  # Called from the specs to simulate invalid server responses
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/resolutionCenter?v=latest").
    to_return(status: 200, body: itc_read_fixture_file('app_resolution_center.json'), headers: { 'Content-Type' => 'application/json' })

  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/resolutionCenter?v=latest").
    to_return(status: 200, body: itc_read_fixture_file('app_resolution_center.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_build_trains
  %w(internal external).each do |type|
    stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/?testingType=#{type}").
      to_return(status: 200, body: itc_read_fixture_file('build_trains.json'), headers: { 'Content-Type' => 'application/json' })

    # Update build trains
    stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/testingTypes/#{type}/trains/").
      to_return(status: 200, body: itc_read_fixture_file('build_trains.json'), headers: { 'Content-Type' => 'application/json' })
  end
end

def itc_stub_testers
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/pre/int").
    to_return(status: 200, body: itc_read_fixture_file('testers/get_internal.json'), headers: { 'Content-Type' => 'application/json' })
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/pre/ext").
    to_return(status: 200, body: itc_read_fixture_file('testers/get_external.json'), headers: { 'Content-Type' => 'application/json' })
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/user/internalTesters/898536088/").
    to_return(status: 200, body: itc_read_fixture_file('testers/existing_internal_testers.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_testflight
  # Reject review
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/trains/1.0/builds/10/reject").
    with(body: "{}").
    to_return(status: 200, body: "{}", headers: { 'Content-Type' => 'application/json' })

  # Prepare submission
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/trains/1.0/builds/10/submit/start").
    to_return(status: 200, body: itc_read_fixture_file('testflight_submission_start.json'), headers: { 'Content-Type' => 'application/json' })
  # First step of submission
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/trains/1.0/builds/10/submit/start").
    to_return(status: 200, body: itc_read_fixture_file('testflight_submission_submit.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_resolution_center_valid
  # Called from the specs to simulate valid server responses
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/resolutionCenter?v=latest").
    to_return(status: 200, body: itc_read_fixture_file('app_resolution_center_valid.json'), headers: { 'Content-Type' => 'application/json' })
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/resolutionCenter?v=latest").
    to_return(status: 200, body: itc_read_fixture_file('app_resolution_center_valid.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_invalid_update
  # Called from the specs to simulate invalid server responses
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/812106519").
    to_return(status: 200, body: itc_read_fixture_file('update_app_version_failed.json'), headers: { 'Content-Type' => 'application/json' })
end

def itc_stub_valid_update
  # Called from the specs to simulate valid server responses
  stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/812106519").
    to_return(status: 200, body: itc_read_fixture_file("update_app_version_success.json"),
                   headers: { "Content-Type" => "application/json" })
end

def itc_stub_app_version_ref
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/ref").
    to_return(status: 200, body: itc_read_fixture_file("app_version_ref.json"),
              headers: { "Content-Type" => "application/json" })
end

def itc_stub_user_detail
  stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/user/detail").
    to_return(status: 200, body: itc_read_fixture_file("user_detail.json"),
              headers: { "Content-Type" => "application/json" })
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    itc_stub_login
    itc_stub_applications
    itc_stub_app_versions
    itc_stub_build_trains
    itc_stub_testers
    itc_stub_testflight
    itc_stub_app_version_ref
    itc_stub_user_detail
    itc_stub_candiate_builds
  end
end
