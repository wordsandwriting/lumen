Lumen::App.controllers do
  
  get '/organisations' do
    sign_in_required!
    erb :'organisations/index'
  end
  
  get '/organisations/cleanup' do
    site_admins_only!
    Organisation.all.each { |organisation|
      organisation.destroy if organisation.affiliations.count == 0      
    }
    redirect '/organisations'
  end
  
  get '/organisations/results' do
    sign_in_required!
    @o = (params[:o] ? params[:o] : 'date').to_sym
    @name = params[:name]
    @sector = params[:sector]
    @q = []
    @q << {:id.in => [Organisation.find_by(name: @name).id]} if @name
    @q << {:id.in => Sectorship.where(sector_id: Sector.find_by(name: @sector)).only(:organisation_id).map(&:organisation_id)} if @sector
    @organisations = Organisation.all
    @organisations = @organisations.and(@q)
    @organisations = case @o
    when :name
      @organisations.order_by(:name.asc)
    when :date
      @organisations.order_by(:updated_at.desc)
    end
    @organisations = @organisations.per_page(10).page(params[:page])
    partial :'organisations/results'
  end  
  
  get '/organisations/:id' do
    sign_in_required!
    @organisation = Organisation.find(params[:id]) || not_found
    erb :'organisations/organisation'
  end
       
  get '/organisations/:id/edit' do
    sign_in_required!
    @organisation = Organisation.find(params[:id]) || not_found
    erb :'organisations/build'
  end
  
  post '/organisations/:id/edit' do
    sign_in_required!
    @organisation = Organisation.find(params[:id]) || not_found
    if @organisation.update_attributes(params[:organisation])      
      flash[:notice] = "<strong>Great!</strong> The organisation was updated successfully."
      redirect "/organisations/#{@organisation.id}/edit"
    else
      flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the organisation from being saved."
      erb :'organisations/build'
    end
  end  
  
  get '/organisations/:id/destroy' do
    sign_in_required!
    @organisation = Organisation.find(params[:id]) || not_found
    @organisation.destroy    
    redirect '/organisations'
  end   
  
end