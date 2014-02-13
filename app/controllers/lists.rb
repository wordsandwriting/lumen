Lumen::App.controllers do
   
  get '/groups/:slug/lists/:id' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @list = @group.lists.find(params[:id])
    erb :'lists/list'
  end
    
  post '/groups/:slug/lists/:id/add_item' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @list = @group.lists.find(params[:id])
    @list.list_items.create :title => params[:title], :link => params[:link], :content => params[:content], :account => current_account
    redirect "/groups/#{@group.slug}/lists/#{@list.id}"
  end
  
  get '/groups/:slug/lists/:id/vote/:list_item_id/:val' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @list = @group.lists.find(params[:id])
    @list_item = @list.list_items.find(params[:list_item_id])
    @list_item.list_item_votes.create(value: params[:val], account: current_account)
    redirect "/groups/#{@group.slug}/lists/#{@list.id}"
  end 
  
  get '/groups/:slug/lists/:id/destroy/:list_item_id' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @list = @group.lists.find(params[:id])
    @list_item = @list.list_items.find(params[:list_item_id])
    @list_item.destroy
    redirect "/groups/#{@group.slug}/lists/#{@list.id}"
  end       
  
  get '/groups/:slug/lists/:id/new' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @list = @group.lists.find(params[:id])
    @list_item = @list.list_items.build
    erb :'lists/list_item'
  end
  
  post '/groups/:slug/lists/:id/new' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @list = @group.lists.find(params[:id])
    @list_item = @list.list_items.build(params[:list_item])
    @list_item.account = current_account
    if @list_item.save  
      flash[:notice] = "<strong>Great!</strong> The item was created successfully."
      redirect "/groups/#{@group.slug}/lists/#{@list.id}"
    else
      flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the item from being saved."
      erb :'lists/list_item'
    end
  end   
  
  get '/groups/:slug/lists/:id/edit/:list_item_id' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @list = @group.lists.find(params[:id])
    @list_item = @list.list_items.find(params[:list_item_id])
    erb :'lists/list_item'
  end
  
  post '/groups/:slug/lists/:id/edit/:list_item_id' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @list = @group.lists.find(params[:id])
    @list_item = @list.list_items.find(params[:list_item_id])
    if @list_item.update_attributes(params[:list_item])
      flash[:notice] = "<strong>Great!</strong> The item was updated successfully."
      redirect "/groups/#{@group.slug}/lists/#{@list.id}"
    else
      flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the item from being saved."
      erb :'lists/list_item'
    end
  end   
      
end