class HomeController < ApplicationController
	require 'net/http'
  def authenticate
  	sso_url = URI("https://v1-sso-api.digitaltown.com/oauth/token")
  	http = Net::HTTP.new(sso_url.host, sso_url.port)
    http.use_ssl = true
    wallet_request = Net::HTTP::Post.new(sso_url)
    wallet_request["content-type"] = 'application/json'
    json_params = "{\"grant_type\":\"password\",\"client_id\":\"375\",\"client_secret\":\"CKNndQmlA13hLP0e1KrVSk8Xt8w1eEkUNePwDu6I\",\"username\":\"tk1@digitaltown.com\",\"password\":\")$dGls*3Ijlk\",\"scope\":\"ID email profile\"}"
    wallet_request.body = json_params
    wallet_response = http.request(wallet_request)
    wallet_response = JSON.parse(wallet_response.read_body)
 		User.create(access_token:  wallet_response["access_token"], refresh_token: wallet_response["access_token"])
 		render(json: wallet_response, status: 200)
  end

  def transfer_token
  	token_amount =  if params[:category_name] == "project"
  		3
  	else
  		2
  	end
  	wallet_to = params[:wallet_id]
  	currency_id = "171"
  	access_token = User.last.access_token
    sender_wallet_id = Rails.application.secrets.sender_wallet_id
    sender_user_id = Rails.application.secrets.sender_user_id
    sender_uu_id = Rails.application.secrets.sender_uu_id
  	wallet_url = URI("https://wallet-api.digitaltown.com/api/v1/wallets/#{sender_wallet_id}/payment?userID=#{sender_user_id}") 
    http = Net::HTTP.new(wallet_url.host, wallet_url.port)
    http.use_ssl = true
    wallet_request = Net::HTTP::Post.new(wallet_url)
    wallet_request["content-type"] = 'application/json'
    wallet_request["Authorization"] = "Bearer #{access_token}"
    wallet_request.body = "{\"userID\":\"#{sender_uu_id}\",\"wallet_to\":\"#{wallet_to}\",\"wallet_amount\":#{token_amount},\"currency_id\":#{currency_id},\"trans_note\":\"test\"}"
    wallet_response = http.request(wallet_request)
    wallet_response = JSON.parse(wallet_response.read_body)
    
    render(json: wallet_response, status: 200)
  end
end
