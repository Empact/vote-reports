ActionController::Routing::Routes.draw do |map|

  map.resources :rolls, :only => [:show]
  map.resources :bills, :only => [:index, :show] do |bill|
    bill.resource :titles, :controller => 'bills/titles', :only => :show
  end
  map.resources :politicians, :only => [:index, :show]
  map.resources :subjects, :only => [:index, :show]
  map.resources :interest_groups, :only => [:index, :show] do |interest_group|
    interest_group.resource :image, :controller => 'interest_groups/images', :only => [:edit, :create, :update]
  end

  map.resources :reports, :only => [:index, :new] do |report|
    report.resources :scores, :controller => 'reports/scores', :only => :show
  end
  map.resource :location
  map.resource :guide

  map.resources :us_states, :as => 'us/states', :controller => 'us/states', :only => 'show' do |state|
    state.resource :map, :controller => 'us/states/maps', :only => 'show'
  end
  map.resources :districts, :as => 'us/congressional_districts', :controller => 'us/districts', :only => 'show' do |district|
    district.resource :map, :controller => 'us/districts/maps', :only => 'show'
  end

  map.resources :reports, :as => '', :name_prefix => 'user_', :path_prefix => "reports/:user_id", :controller => 'users/reports' do |report|
    report.resource :image, :as => 'thumbnail', :only => [:edit, :update, :create], :controller => 'users/reports/thumbnails'
    report.resources :bill_criteria, :only => [:index, :new, :destroy], :controller => 'users/reports/bill_criteria'
  end

  map.about "about", :controller => "site", :action => "show"  

  map.resources :user_sessions
  map.resources :users do |user|
    user.resources :rpx_identities, :only => [:create, :destroy], :controller => 'users/rpx_identities'
    user.resource :adminship, :only => [:create, :destroy], :controller => 'users/adminships'
    user.resource :moderatorship, :only => [:create, :destroy], :controller => 'users/moderatorships'
  end

  map.signup "/signup", :controller => "users", :action => "new"  
  map.login "/login", :controller => "user_sessions", :action => "new"
  map.logout "/logout", :controller => "user_sessions", :action => "destroy"  

  Jammit::Routes.draw(map)

  map.root :controller => "site", :action => 'index'
end
