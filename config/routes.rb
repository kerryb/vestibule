Vestibule::Application.routes.draw do
  resources :users, :only => [:show, :edit, :update]
  resources :proposals, :except => [:destroy] do
    resources :suggestions, :only => [:create]
    member do
      post :withdraw
    end
  end
  resources :selections, :only => [:index, :create, :destroy]

  match "/motivation", :to => "home#motivation", :as => "motivation"
  match "/about", :to => "home#about", :as => "about"
  match "/my-motivation", :to => "home#my_motivation", :as => "complete_motivation"
  match "/anonymous-proposals", :to => "home#anonymous_proposals", :as => "anonymous_proposals"
  match "/the-vestibule-process", :to => "home#the_vestibule_process", :as => "the_vestibule_process"

  match "/dashboard", :to => "dashboard#index"

  match "/auth/iuser/callback", :to => "iuser_authentication#callback"
  match "/auth/failure", :to => "iuser_authentication#failure"
  match "/logout", :to => "iuser_authentication#logout", :as => "logout"

  root :to => "home#index"
end
