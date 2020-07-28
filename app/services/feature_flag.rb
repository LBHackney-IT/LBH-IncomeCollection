class FeatureFlag
  FEATURES = %w[
    create_informal_agreements
    create_formal_agreements
  ].freeze

  def self.activate(feature_name)
    return if Rails.env.production? # Features should be activated using ENV vars in production

    raise unless feature_name.in?(FEATURES)

    ENV[feature_name] = 'true'
  end

  def self.deactivate(feature_name)
    return if Rails.env.production? # Features should be deactivated using ENV vars in production

    raise unless feature_name.in?(FEATURES)

    ENV[feature_name] = 'false'
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV[feature_name].present? && ENV[feature_name] == 'true'
  end
end
