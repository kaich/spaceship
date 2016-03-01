require 'spaceship'



module Spaceship

  #client.login("jobkai1853@163.com","Xuzhongting#1219")
  #client.login("331750166@qq.com","Heyuzu4680129")
  #client.login("1304309543@qq.com","I4ppdappda")

  Spaceship.login("jobkai1853@163.com","Xuzhongting#1219")

#begin

  #puts Spaceship.device.all
  #puts "------------------result #{Spaceship.provisioning_profile.all}}"
  Spaceship.device.create!(name: "iphone 3" ,udid: "87600f350d92a7b4aaeb5935c075fb9f232c6e18")
  puts "------------------result #{Spaceship.provisioning_profile.create!(name: "xiaoming", bundle_id: "xiaoming.test123418.com")}"
  #p = Spaceship.provisioning_profile.find_by_bundle_id("Krunoslav-Zaher.RxExample97-iOS-no-module") 
  #puts "------------------result #{p} : #{p.download }"
  #puts client.api_key
#rescue => error
  #puts "----------------------------Could not login to iTunes Connect...--------------------------------"
  #puts error 
#end

#puts "-------------------------#{client.create_device!("iPhone (3)","87600f350d92a7b4aaeb5935c075fb9f232c6e18")}"
#puts "-------------------------#{client.download_provisioning_profile "27W2P6UW77"}"
#puts "-------------------------#{client.certificates}"


#Spaceship::Portal.login("jobkai1853@163.com")

#device = Spaceship::Portal::Device.set_client(@client)

#puts device.all

end

