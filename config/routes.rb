Rails.application.routes.draw do
  root  'home#top'
  get   'search' => 'home#index'
  post  'search' => 'home#index'
  # get   'insert' => 'home#insert'
end
