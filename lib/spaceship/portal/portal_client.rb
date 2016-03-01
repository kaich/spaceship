module Spaceship
  class PortalClient < Spaceship::Client
    #####################################################
    # @!group Init and Login
    #####################################################
    
     #def initialize
       #super()
     #end

    def self.hostname
      "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/"
    end

    # Fetches the latest API Key from the Apple Dev Portal
    def api_key
       "ba2ec180e6ca6e6c6a542255453b24d6e6e5b2be0cc48bc1b0d8ad64cfe0228f"
    end

    def user_locale
      "en_US"
    end

    def client_id 
      "XABBG36SBA"
    end

    def send_login_request(user, password)
      response = request(:post, "https://idmsa.apple.com/IDMSWebAuth/clientDAW.cgi", {
        appleId: user,
        password: password,
        appIdKey: api_key,
        userLocale: user_locale,
        protocolVersion: LOGIN_PROTOCOL_VERSION,
        format: "plist"
      },{},false)

      content = parse_response(response)
      if content.kind_of? Hash
        @myacinfo = content["myacinfo"]
        @request_cookie = "myacinfo=#{@myacinfo}"
      end 
      
      if (response.body || "").include?("Your Apple ID or password was entered incorrectly")
        # User Credentials are wrong
        raise InvalidUserCredentialsError.new, "Invalid username and password combination. Used '#{user}' as the username."
      elsif (response.body || "").include?("Verify your identity")
        raise "spaceship / fastlane doesn't support 2 step enabled accounts yet. Please temporary disable 2 step verification until spaceship was updated."
      end

      case response.status
      when 302
        return response
      when 200
        puts "Login apple server successful!"
        return response
      else
        # Something went wrong. Was it invalid credentials or server issue
        info = [response.body, response['Set-Cookie']]
        raise UnexpectedResponse.new, info.join("\n")
      end

    end



    # @return (Array) A list of all available teams
    def teams

      req = request(:post, "https://developerservices2.apple.com/services/QH65B2/listTeams.action?clientId=#{client_id}",{
        client: client_id,
        myacinfo: @myacinfo,
        protocolVersion: PROTOCOL_VERSION,
        requestId: @requestId,
        userLocale: [user_locale],

      })
      teams = parse_response(req, 'teams')
      if !teams
        return []
      end
      return teams
    end

    # @return (String) The currently selected Team ID
    def team_id
      return @current_team_id if @current_team_id

      if teams.count > 1
        puts "The current user is in #{teams.count} teams. Pass a team ID or call `select_team` to choose a team. Using the first one for now."
      end
      if teams.count > 0
        @current_team_id ||= teams[0]['teamId']
      end

      #@current_team_id = "LD2L85QJW4"
    end

    # Shows a team selection for the user in the terminal. This should not be
    # called on CI systems
    def select_team
      @current_team_id = self.UI.select_team
    end

    # Set a new team ID which will be used from now on
    def team_id=(team_id)
      @current_team_id = team_id
    end

    # @return (Hash) Fetches all information of the currently used team
    def team_information
      teams.find do |t|
        t['teamId'] == team_id
      end
    end

    # Is the current session from an Enterprise In House account?
    def in_house?
      return @in_house unless @in_house.nil?
      @in_house = (team_information['type'] == 'In-House')
    end

    def platform_slug(mac)
      if mac
        'mac'
      else
        'ios'
      end
    end
    private :platform_slug

   
    #####################################################
    # @!group Devices
    #####################################################

    def devices(mac: false)
      paging do |page_number|
        r = request(:post, "https://developerservices2.apple.com/services/QH65B2/mac/listDevices.action?clientId=#{client_id}", {
        client: client_id,
        teamId: team_id,
        protocolVersion: PROTOCOL_VERSION,
        requestId: @requestId,
        userLocale: [user_locale],

      })
        parse_response(r, 'devices')
      end
    end


    def create_device!(device_name, device_id, mac: false)
      req = request(:post , "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/#{platform_slug(mac)}/addDevice.action", {
          clientId: client_id,
          teamId: team_id,
          deviceNumber: device_id,
          name: device_name,
          protocolVersion: PROTOCOL_VERSION,
          requestId: @requestId,
          userLocale: [user_locale],
        })

      #parse_response(req, 'device')
      content = parse_response(req)
      if req.body.include? "already exists on this team"
        msg = content["validationMessages"][0]
        puts  msg
        content
      else
        content 
      end 
    end

    #####################################################
    # @!group Certificates
    #####################################################

    def certificates(types = "dev", mac: false)
      paging do |page_number|
        r = request(:post, "https://developerservices2.apple.com/services/QH65B2/#{platform_slug(mac)}/listAllDevelopmentCerts.action?clientId=#{client_id}", {
          clientId: client_id,
          teamId: team_id,
          requestId: @requestId,
          protocolVersion: PROTOCOL_VERSION,
          userLocale: [user_locale],
        })
        parse_response(r, 'certificates')
      end
    end



    #####################################################
    # @!group Provisioning Profiles
    #####################################################

    def provisioning_profiles(mac: false)
      req = request(:post,"https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/#{platform_slug(mac)}/listProvisioningProfiles.action?clientId=#{client_id}",{
          clientId: client_id,
          teamId: team_id,
          includeInactiveProfiles: true,
          requestId: @requestId,
          protocolVersion: PROTOCOL_VERSION,
          userLocale: [user_locale],
        })

      parse_response(req, 'provisioningProfiles')
    end

    def create_provisioning_profile!(name, app_id, mac: false)
      req = request(:post,"https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/#{platform_slug(mac)}/addAppId.action?clientId=#{client_id}",{
          clientId: client_id,
          appIdName: name, 
          entitlements: [],
          identifier: app_id,
          teamId: team_id,
          name: name,
          requestId: @requestId,
          protocolVersion: PROTOCOL_VERSION,
          userLocale: [user_locale],
        })

      content = parse_response(req)
      if content
        app = content["appId"]
        if app
          appIdId = app["appIdId"]
          download_not_exist_provisioning_profile(appIdId)
        end
      end
    end


    def download_not_exist_provisioning_profile(profile_id, mac: false)
      r = request(:post, "https://developerservices2.apple.com/services/QH65B2/#{platform_slug(mac)}/downloadTeamProvisioningProfile.action?clientId=#{client_id}", {
        clientId: client_id,
        protocolVersion: PROTOCOL_VERSION,
        teamId: team_id,
        appIdId: profile_id,
        requestId: @requestId,
        userLocale: [user_locale],
      })
      a = parse_response(r,'provisioningProfile')
      if r.success? && a
        return a['encodedProfile'].read
      else
        raise UnexpectedResponse.new, "Couldn't download provisioning profile, got this instead: #{a}"
      end
    end

    def download_provisioning_profile(profile_id, mac: false)
      r = request(:post, "https://developerservices2.apple.com/services/QH65B2/#{platform_slug(mac)}/downloadProvisioningProfile.action?clientId=#{client_id}", {
        clientId: client_id,
        protocolVersion: PROTOCOL_VERSION,
        teamId: team_id,
        provisioningProfileId: profile_id,
        requestId: @requestId,
        userLocale: [user_locale],
      })
      a = parse_response(r,'provisioningProfile')
      if r.success? && a
        return a['encodedProfile'].read
      else
        raise UnexpectedResponse.new, "Couldn't download provisioning profile, got this instead: #{a}"
      end
    end





    def repair_provisioning_profile!(profile_id, name, distribution_method, app_id, certificate_ids, device_ids, mac: false)
      #r = request(:post, "account/#{platform_slug(mac)}/profile/regenProvisioningProfile.action", {
        #teamId: team_id,
        #provisioningProfileId: profile_id,
        #provisioningProfileName: name,
        #appIdId: app_id,
        #distributionType: distribution_method,
        #certificateIds: certificate_ids.join(','),
        #deviceIds: device_ids
      #})

      #parse_response(r, 'provisioningProfile')
    end

    private

    def ensure_csrf
      if csrf_tokens.count == 0
        # If we directly create a new resource (e.g. app) without querying anything before
        # we don't have a valid csrf token, that's why we have to do at least one request
        apps
      end
    end
  end
end
