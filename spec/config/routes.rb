TestApp.routes.draw do
  resources :users, :posts
  get 'exit' => proc { exit! }
  get 'pry' => proc { binding.pry; [200, {}, ['']] }
end