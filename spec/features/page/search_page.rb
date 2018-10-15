module Pages
  class Search
    include Capybara::DSL

    attr_reader :URL

    URL = '/search'.freeze

    def go
      visit '/auth/azureactivedirectory'
      visit URL
    end

    def search_field
      find 'input#search_term'
    end

    def results
      all('.tenancy_list > tbody > tr')
    end

    def search_for(keyword)
      search_field.set(keyword)
      click_on 'submit'
    end
  end
end
