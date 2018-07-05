Rails.application.routes.draw do
  
  match 'transfer' => 'home#transfer_token', via: [:get, :post]
  match 'authenticate' => 'home#authenticate', via: [:get, :post]
  # resources :home do
  # 	collection do
  # 		get :authenticate
  # 		post :transfer_token
  # 	end
  # end
end
