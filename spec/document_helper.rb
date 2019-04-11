def example_document(attributes = {})
  uuid = attributes.fetch(:uuid, SecureRandom.uuid)
  extension = attributes.fetch(:extension, '.pdf')
  metadata = attributes.fetch(:metadata, example_metadata)

  date_time = '2019-03-27T16:57:49.175Z'

  attributes.reverse_merge(
    id: Faker::Number.number(2),
    uuid: uuid,
    extension: extension,
    metadata: metadata,
    filename: uuid + extension,
    mime_type: 'application/pdf',
    status: 'uploading',
    created_at: date_time,
    updated_at: date_time,
  )
end

def example_metadata(attributes = {})
  attributes.reverse_merge(
    user_id: Faker::Number.number(3),
    payment_ref: Faker::Number.number(9),
    template:
      {
        path: Faker::LeagueOfLegends.rank,
        name: Faker::LeagueOfLegends.champion,
        id: Faker::LeagueOfLegends.location
      }
  )
end
