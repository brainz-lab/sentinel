Rails.application.routes.draw do
  # Root redirects to dashboard
  root to: redirect('/dashboard')

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboard routes
  namespace :dashboard do
    root to: 'overview#index'

    resources :hosts do
      member do
        get :metrics
        get :processes
        get :containers
      end
    end

    resources :host_groups
    resources :alert_rules
  end

  # API v1
  namespace :api do
    namespace :v1 do
      # Hosts
      resources :hosts do
        member do
          get :metrics
          get :processes
          get :health
        end
        resources :containers, only: [:index, :show]
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
    post 'agent', to: 'agent#create'
    post 'agent/register', to: 'agent#register'
  end

  # MCP
  namespace :mcp do
    post 'tools/:tool', to: 'tools#execute'
    get 'tools', to: 'tools#list'
  end

  # ActionCable mount
  mount ActionCable.server => '/cable'
end
