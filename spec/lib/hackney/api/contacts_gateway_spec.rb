# describe Hackney::API::ContactsGateway do
#   subject { described_class.new }
#
#   describe 'retrieving a contact' do
#     it 'should return contact details' do
#       expect(subject.get_contact(307264)).to eq(
#         title: 'MR',
#         forenames: 'CHRISTOPHER',
#         surname: 'SMITH',
#         email: nil,
#         phone_numbers: {
#           mobile: '07908156213',
#           home: nil
#         },
#         address: {
#           number: '1',
#           street: 'ETHELBERT HOUSE',
#           address_2: 'HOMERTON ROAD',
#           address_3: 'HACKNEY',
#           address_4: 'LONDON',
#           post_code: 'E9 5PL'
#         }
#       )
#     end
#   end
# end
