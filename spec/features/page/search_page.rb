module Page
  class Search
    include Capybara::DSL

    attr_reader :URL

    URL = '/search'.freeze

    def go
      visit '/auth/azureactivedirectory'
      visit URL
    end

    def first_name_field
      find 'input#first_name'
    end

    def last_name_field
      find 'input#last_name'
    end

    def address_field
      find 'input#address'
    end

    def post_code_field
      find 'input#post_code'
    end

    def tenancy_ref_field
      find 'input#tenancy_ref'
    end

    def results
      all('.tenancy_list > tbody > tr')
    end

    def search_for_tenancy(keyword)
      tenancy_ref_field.set(keyword)
      click_on 'submit'
    end
  end
end
