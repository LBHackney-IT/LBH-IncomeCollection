module Page
  class Worktray
    include Capybara::DSL

    attr_reader :URL

    URL = '/worktray'.freeze

    def go
      visit '/auth/azureactivedirectory'
      visit URL
    end

    def click_paused_tab!
      click_link 'Paused'
    end

    def results
      all('.tenancy_list > tbody > tr')
    end
  end
end
