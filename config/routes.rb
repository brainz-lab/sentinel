Rails.application.routes.draw do
  # Root redirects to dashboard
  root to: redirect("/dashboard")

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboard routes
  namespace :dashboard do
    root to: "projects#index"

    resources :projects, only: [ :index, :show, :new, :create ] do
      # Project-scoped resources
      get "/", to: "overview#index", as: :overview

      # Hosts
      get "hosts/new", to: "hosts#new", as: :new_host
      get "hosts/:id/edit", to: "hosts#edit", as: :edit_host
      resources :hosts, except: [ :new, :edit ] do
        member do
          get :metrics
          get :processes
          get :containers
        end
      end

      # Host Groups
      get "host_groups/new", to: "host_groups#new", as: :new_host_group
      get "host_groups/:id/edit", to: "host_groups#edit", as: :edit_host_group
      resources :host_groups, except: [ :new, :edit ]

      # Alert Rules
      get "alert_rules/new", to: "alert_rules#new", as: :new_alert_rule
      get "alert_rules/:id/edit", to: "alert_rules#edit", as: :edit_alert_rule
      resources :alert_rules, except: [ :new, :edit ]
    end
  end

  # API v1
  namespace :api do
    namespace :v1 do
      # Project provisioning (Platform integration)
      resources :projects, only: [] do
        collection do
          post :provision
          get :lookup
        end
      end

      # Hosts
      resources :hosts do
        member do
          get :metrics
          get :processes
          get :health
        end
        resources :containers, only: [ :index, :show ]
      end

      # Host Groups
      resources :host_groups

      # Alert Rules
      resources :alert_rules do
        member do
          post :test
          post :enable
          post :disable
        end
      end

      # Dashboard endpoints
      namespace :dashboard do
        get :fleet
        get :capacity
      end
    end
  end

  # Internal agent endpoint
  namespace :internal do
    post "agent", to: "agent#create"
    post "agent/register", to: "agent#register"
  end

  # MCP
  namespace :mcp do
    post "tools/:tool", to: "tools#execute"
    get "tools", to: "tools#list"
  end

  # ActionCable mount
  mount ActionCable.server => "/cable"
end
