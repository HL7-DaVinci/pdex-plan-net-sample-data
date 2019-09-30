require 'faker'

module PDEX
  module Fakes
    def fake_first_name
      Faker::Name.first_name
    end

    def fake_gendered_name(gender)
      gender == 'F' ? Faker::Name.female_first_name : Faker::Name.male_first_name
    end

    def fake_family_name
      Faker::Name.last_name
    end

    def fake_npi(npi)
      '123' + npi[3..-1]
    end

    def fake_phone_number
      Faker::PhoneNumber.phone_number
    end

    def fake_license_number
      Faker::Number.number(6)
    end

    def fake_pharmacy_credential(credential)
      final_digit = credential[-1]
      credential[-1] = credential[-4]
      credential[-4] = final_digit
      credential
    end
  end
end
