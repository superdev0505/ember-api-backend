Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  # Every model should have jsonapi-resources routes
  # exclude = %w(ahoy application_record)
  # Dir.foreach("#{Rails.root}/app/models") do |model_name|
  #   puts model_name.split(".")[0]
  #   name = model_name.split(".")[0]
  #   if name && !exclude.include?(name)
  #     jsonapi_resources name
  #   end
  #   # puts name
  #   # jsonapi_resources name.to_sym
  # end
  jsonapi_resources :users
  jsonapi_resources :job_titles
  jsonapi_resources :user_locations
  jsonapi_resources :locations
  jsonapi_resources :email_accounts

  jsonapi_resources :conversations
  jsonapi_resources :conversation_members
  jsonapi_resources :messages
  jsonapi_resources :alerts

  jsonapi_resources :availabilities
  jsonapi_resources :availability_users

  jsonapi_resources :availability_items
  jsonapi_resources :resource_textbooks
  jsonapi_resources :resource_websites

  jsonapi_resources :feedback_requests
  jsonapi_resources :feedbacks
  jsonapi_resources :feedback_questions
  jsonapi_resources :feedback_question_responses
  jsonapi_resources :logbook_entries

  jsonapi_resources :availability_requests
  jsonapi_resources :availability_request_votes

  jsonapi_resources :notification_preferences

  jsonapi_resources :specialties


  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    confirmations: 'confirmations'
  }

  # Additional routes
  post 'users/forgot_password', to: 'users#forgot_password'
  post 'users/resend_confirmation_email', to: 'users#resend_confirmation_email'
  post 'users/test_confirm', to: 'users#test_confirm'
  post 'users/:id/change_password', to: 'users#change_password'
  post 'users/upload_avatar', to: 'users#upload_avatar'
  post 'users/delete_avatar', to: 'users#delete_avatar'

  post 'email_accounts/:id/resend_confirmation', to: 'email_accounts#resend_confirmation'
  post 'email_accounts/:id/submit_confirmation_code', to: 'email_accounts#submit_confirmation_code'
  post 'alerts/mark_read', to: 'alerts#mark_read'
  post 'feedbacks/download_report', to: 'feedbacks#download_report'

  get 'resource_textbooks/kortext_search', to: 'resource_textbooks#kortext_search'
  get 'resource_textbooks/:id/click', to: 'resource_textbooks#click'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
