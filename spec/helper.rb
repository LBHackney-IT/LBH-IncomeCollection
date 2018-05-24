module Helper
  def stub_authentication
    request.session[:current_user] = { name: 'Batch Roast' }
  end
end
