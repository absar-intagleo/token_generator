class HomeController < ApplicationController

	before_action :validate_params, only: :transfer_token
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
    trans_note = ""

    token_amount =  if params[:category_name].downcase.eql?("project")
      if params[:category_child_id].eql?("1")
        trans_note = "Awarded for creating project."
        3
      elsif params[:category_child_id].eql?("2")
        "Awarded for volunteering the project."
        2
      end 
    elsif params[:category_name].downcase.eql?("discussion")
      if params[:category_child_id].eql?("1")
        trans_note = "Awarded for creating a discussion "
        2
      elsif params[:category_child_id].eql?("2")
        trans_note = "Awarded for voting in the poll."
        1
      end
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
    wallet_request.body = "{\"userID\":\"#{sender_uu_id}\",\"wallet_to\":\"#{wallet_to}\",\"wallet_amount\":#{token_amount},\"currency_id\":#{currency_id},\"trans_note\":\"#{trans_note}\"}"
    wallet_response = http.request(wallet_request)
    wallet_response = JSON.parse(wallet_response.read_body)
    
    render(json: wallet_response, status: 200)
  end

  private
  def validate_params
  	error_message = []
   	error_message << "Please provide wallet_id" if !params[:wallet_id].present?
   	error_message << "Please provide category_name" if !params[:category_name].present?
   	error_message << "Please provide category_name" if !params[:category_child_id].present?
  	render(json: {error: error_message.join(', ')}, status: 400) if error_message.present?
  end
end
