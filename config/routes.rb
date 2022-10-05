Rails.application.routes.draw do
  get 'notifications/next_to_run' 
  get 'notifications/waiting'
  get 'notifications/next_runs'
  put 'notifications/snooze'
  put 'notifications/mark_as'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
