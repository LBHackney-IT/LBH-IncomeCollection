require 'rails_helper'
describe HotjarHelper, type: :helper do
  context 'has key/version defined' do
    before do
      Rails.application.config.x.hotjar_key = Faker::IDNumber.spanish_citizen_number
      Rails.application.config.x.hotjar_version = Faker::Number.number(digits: 5).to_s
    end

    it { expect(hotjar_tags).to include('<script>') }
    it { expect(hotjar_tags).to include('(function(h,o,t,j,a,r)') }
    it { expect(hotjar_tags).to include(Rails.application.config.x.hotjar_key) }
    it { expect(hotjar_tags).to include(Rails.application.config.x.hotjar_version) }
  end

  context 'key not defined' do
    before { Rails.application.config.x.hotjar_key = nil }
    it { expect(hotjar_tags).to_not include('<script>') }
  end
end
