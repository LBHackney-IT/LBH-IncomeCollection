def example_document(attributes = {})
  uuid = attributes.fetch(:uuid, SecureRandom.uuid)
  extension = attributes.fetch(:extension, '.pdf')
  metadata = attributes.fetch(:metadata, example_metadata)
  status = attributes.fetch(:status, 'uploading')

  date_time = '2019-03-27T16:57:49.175Z'

  attributes.reverse_merge(
    id: Faker::Number.number(digits: 2),
    uuid: uuid,
    extension: extension,
    metadata: metadata,
    filename: uuid + extension,
    mime_type: 'application/pdf',
    status: status,
    created_at: date_time,
    updated_at: date_time
  )
end

def example_metadata(attributes = {})
  attributes.reverse_merge(
    user_id: Faker::Number.number(digits: 3),
    payment_ref: Faker::Number.number(digits: 9),
    template:
      {
        path: Faker::Games::LeagueOfLegends.rank,
        name: Faker::Games::LeagueOfLegends.champion,
        id: Faker::Games::LeagueOfLegends.location
      }
  )
end
