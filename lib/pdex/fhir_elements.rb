require_relative 'utils/nucc_codes'

module PDEX
  module FHIRElements
    def nucc_codeable_concept(qualification)
      display = NUCCCodes.specialty_display(qualification.taxonomy_code)
      {
        coding: [
          {
            system: 'http://nucc.org/provider-taxonomy',
            code: qualification.taxonomy_code,
            display: display
          }
        ],
        text: display
      }
    end
  end
end
