require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/bananajour"

gem 'sinatra', '0.9.1.1'
require 'sinatra'

gem 'json', '1.1.2'
require 'json'

require 'digest/md5'

disable :logging
set :environment, :production

load "#{File.dirname(__FILE__)}/lib/date_helpers.rb"
helpers DateHelpers

helpers do
  def json(body)
    content_type "application/json"
    params[:callback] ? "#{params[:callback]}(#{body});" : body
  end
  def view(view)
    haml view, :options => {:format => :html5,
                              :attr_wrapper => '"'}
  end
  def versioned_javascript(js)
    "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
  end
end

get "/" do
  @repositories = Bananajour.repositories
  @network_repositories = Bananajour.network_repositories
  view :home
end

get "/:repository/readme" do
  @repository = Bananajour::Repository.for_name(params[:repository])
  readme_file = @repository.readme_file
  @rendered_readme = @repository.rendered_readme
  @plain_readme = readme_file.data
  view :readme
end

get "/index.json" do
  json Bananajour.to_hash.to_json
end

get "/:repository.json" do
  json Bananajour::Repository.for_name(params[:repository]).to_hash.to_json
end
