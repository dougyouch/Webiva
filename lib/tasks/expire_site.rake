namespace 'cms' do
  desc "Expire site cache"
  task :expire_site => [:environment] do
    domain_id = ENV['DOMAIN_ID'] || raise('Missing DOMAIN_ID=## argument')
    DomainModel.activate_domain domain_id.to_i, 'production'
    DomainModel.expire_site
  end
end
