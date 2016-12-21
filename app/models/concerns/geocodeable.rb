module Geocodeable
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :geocodeable_address_attr, :geocodeable_lat_attr,
                :geocodeable_lng_attr

    private

    def geocode_attrs(address:, latitude:, longitude:)
      @geocodeable_address_attr = address
      @geocodeable_lat_attr = latitude
      @geocodeable_lng_attr = longitude

      geocoded_by address,
                  latitude: latitude,
                  longitude: longitude

      before_validation :geocode, if: -> (obj) {
        obj.send(address).present? and
          obj.send("#{address}_changed?")
      }
    end
  end
end
