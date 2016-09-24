# This module provides additional fake data generators (in addition to Faker)
module HCFaker
  class HighSchool
    class << self
      def name
        "#{Faker::Address.city} High School"
      end
    end
  end

  class Address
    class << self
      def full_address
        "#{Faker::Address.street_address}, #{Faker::Address.city}, #{Faker::Address.state_abbr} #{Faker::Address.zip_code}"
      end
    end
  end
end