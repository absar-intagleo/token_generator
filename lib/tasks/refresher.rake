namespace :refresher do
  desc "TODO"
  task refresh_token: :environment do
  	sso_url = URI("https://v1-sso-api.digitaltown.com/oauth/token")
  	http = Net::HTTP.new(sso_url.host, sso_url.port)
    http.use_ssl = true
    wallet_request = Net::HTTP::Post.new(sso_url)
    wallet_request["content-type"] = 'application/json'
    json_params = "{\"grant_type\":\"password\",\"client_id\":\"375\",\"client_secret\":\"CKNndQmlA13hLP0e1KrVSk8Xt8w1eEkUNePwDu6I\",\"username\":\"tk1@digitaltown.com\",\"password\":\")$dGls*3Ijlk\",\"scope\":\"ID email profile\"}"
    wallet_request.body = json_params
    wallet_response = http.request(wallet_request)
    wallet_response = JSON.parse(wallet_response.read_body)
    
    users = Rails.env.development? ? User.all : User.where('Date(updated_at) <= ?', 29.days.ago) 
 	users.each do |user|
		user.update_attributes(access_token:  wallet_response["access_token"], refresh_token: wallet_response["access_token"])
	end
  end

end
