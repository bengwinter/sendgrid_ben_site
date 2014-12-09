require 'sinatra'
require 'action_mailer'
require 'sinatra/cross_origin'
require 'dotenv'


set :server, 'webrick'

configure do
  enable :cross_origin
end

before do
   content_type :json    
   headers 'Access-Control-Allow-Origin' => '*', 
           'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
           'Access-Control-Allow-Headers' => 'Content-Type'  
end

set :protection, false

class Mailer < ActionMailer::Base
  def contact(first, last, contact_email, message)
    @first = first
    @last = last
    @contact_email = contact_email
    @message = message
    mail(
      :to      => "ben.g.winter@gmail.com",
      :from    => "contact@benwinter.co",
      :subject => "Message from Personal Website") do |format|
        format.text
        format.html
    end
  end

  def contact_julycamp(name, contact_email, services, message)
    @name = name
    @contact_email = contact_email
    @message = message
    @services = services
    mail(
      :to      => "ben.g.winter@gmail.com",
      :from    => "contact@julycamp.com",
      :subject => "Message from July Camp Website") do |format|
        format.text
        format.html
    end
  end
end
 
configure do
  set :root,    File.dirname(__FILE__)
  set :views,   File.join(Sinatra::Application.root, 'views')
  set :haml,    { :format => :html5 }
    
  if production?
    ActionMailer::Base.smtp_settings = {
      :address => "smtp.sendgrid.net",
      :port => '25',
      :authentication => :plain,
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :domain => ENV['SENDGRID_DOMAIN'],
    }
    ActionMailer::Base.view_paths = File.join(Sinatra::Application.root, 'views')
  else
    ActionMailer::Base.delivery_method = :file
    ActionMailer::Base.file_settings = { :location => File.join(Sinatra::Application.root, 'tmp/emails') }
    ActionMailer::Base.view_paths = File.join(Sinatra::Application.root, 'views')
  end
end
 
post '/mail' do
  cross_origin :allow_origin => ENV['ALLOWED_DOMAIN_PERSONAL_SITE'].to_s,
    :allow_methods => [:get, :post, :options]

  first = params["firstName"]
  last = params["lastName"]
  contact_email = params["email"]
  message = params["message"]

  if request.referrer.include?(ENV['ALLOWED_DOMAIN_PERSONAL_SITE'].to_s)
    email = Mailer.contact(first, last, contact_email, message)
    email.deliver
  end
end

post '/mail_july_camp' do
  cross_origin :allow_origin => ENV['ALLOWED_DOMAIN_JULY_CAMP'].to_s,
    :allow_methods => [:get, :post, :options]

  name = params["name"]
  contact_email = params["email"]
  services = ''
  if params["services"] == [] 
    params["services"].each do |service|
      services += service
    end
  end
  
  message = params["message"]

  if request.referrer.include?(ENV['ALLOWED_DOMAIN_JULY_CAMP'].to_s)
    email = Mailer.contact_julycamp(name, contact_email, services, message)
    email.deliver
  end
end


get '/' do
  erb :layout
end