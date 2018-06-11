module Helper
  def stub_authentication
    request.session[:current_user] = {
      'id' => 123,
      'name' => 'Batch Roast',
      'email' => 'batchy@example.com'
    }
  end
end
