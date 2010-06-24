ActionController::Routing::Routes.draw do |map|
  map.resource :search, :only => :show

  map.resources :causes do |cause|
    cause.resources :scores, :controller => 'causes/scores', :only => [:index, :show]
    cause.resource :follows, :controller => 'causes/follows', :only => [:show, :create, :destroy]
    cause.resources :reports, :controller => 'causes/reports', :only => [:new, :create, :index, :destroy]
  end
  map.resources :reports, :only => [:index, :new]
  map.resources :reports, :as => '', :name_prefix => 'user_', :path_prefix => "reports/:user_id", :controller => 'users/reports' do |report|
    report.resources :scores, :controller => 'users/reports/scores', :only => [:index, :show]
    report.resource :follows, :controller => 'users/reports/follows', :only => [:show, :create, :destroy]
    report.resources :causes, :controller => 'users/reports/causes', :only => :index
    report.resources :subjects, :controller => 'users/reports/subjects', :only => :index
    report.resource :agenda, :controller => 'users/reports/agendas', :only => :show
    report.resource :visibility, :controller => 'users/reports/visibilities', :only => :show
    report.resource :image, :as => 'thumbnail', :only => [:edit, :update, :create], :controller => 'users/reports/thumbnails'
    report.resources :bill_criteria, :only => [:index, :new, :create, :destroy], :controller => 'users/reports/bill_criteria'
  end
  map.resources :interest_groups, :only => [:index, :show] do |interest_group|
    interest_group.resources :scores, :controller => 'interest_groups/scores', :only => [:index, :show]
    interest_group.resource :follows, :controller => 'interest_groups/follows', :only => [:show, :create, :destroy]
    interest_group.resources :causes, :controller => 'interest_groups/causes', :only => :index
    interest_group.resources :subjects, :controller => 'interest_groups/subjects', :only => :index
    interest_group.resource :agenda, :controller => 'interest_groups/agendas', :only => :show
    interest_group.resource :image, :controller => 'interest_groups/images', :only => [:edit, :create, :update]
  end
  map.resources :politicians, :only => [:index, :show] do |politician|
    politician.resources :causes, :controller => 'politicians/causes', :only => :index
    politician.resources :reports, :controller => 'politicians/reports', :only => :index
  end
  map.resources :subjects, :only => [:index, :show] do |subject|
    subject.resources :causes, :controller => 'subjects/causes', :only => :index
    subject.resources :reports, :controller => 'subjects/reports', :only => :index
    subject.resources :bills, :controller => 'subjects/bills', :only => :index
  end
  map.resources :bills, :only => [:index, :show] do |bill|
    bill.resource :titles, :controller => 'bills/titles', :only => :show
  end
  map.resources :rolls, :only => [:show]

  map.resource :location
  map.resources :guides, :only => [:new, :create, :show]

  map.resources :us_states, :as => 'us/states', :controller => 'us/states', :only => 'show' do |state|
    state.resource :map, :controller => 'us/states/maps', :only => 'show'
  end
  map.resources :congressional_districts, :as => 'us/congressional_districts', :controller => 'us/congressional_districts', :only => 'show' do |congressional_district|
    congressional_district.resource :map, :controller => 'us/congressional_districts/maps', :only => 'show'
  end

  map.resources :users do |user|
    user.resources :rpx_identities, :only => [:create, :destroy], :controller => 'users/rpx_identities'
    user.resource :adminship, :only => [:create, :destroy], :controller => 'users/adminships'
    user.resource :moderatorship, :only => [:create, :destroy], :controller => 'users/moderatorships'
    user.resources :scores, :only => :index, :controller => 'users/scores'
  end
  map.resources :user_sessions

  map.signup "/signup", :controller => "users", :action => "new"
  map.login "/login", :controller => "user_sessions", :action => "new"
  map.logout "/logout", :controller => "user_sessions", :action => "destroy"

  map.new_donation '/donate', :controller => :donations, :action => :new
  map.donation_thanks '/thanks', :controller => :donations, :action => :show
  map.resource :donations

  map.about "about", :controller => "site", :action => "show"
  map.root :controller => "site", :action => 'index'

  Jammit::Routes.draw(map)
end
