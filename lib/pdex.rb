require 'active_support'
require 'active_support/core_ext/object'

module PDEX
  PRACTITIONER_PROFILE_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/vhdir-practitioner'
  ORGANIZATION_PROFILE_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/vhdir-organization'
  LOCATION_PROFILE_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/vhdir-location'

  ACCESSIBILITY_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/accessibility'
  CONTACT_POINT_AVAILABLE_TIME_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/contactpoint-availabletime'
  NEW_PATIENTS_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/newpatients'
  NEW_PATIENT_PROFILE_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/newpatientprofile'

  ACCESSIBILITY_CODE_SYSTEM_URL = 'http://hl7.org/fhir/uv/vhdir/CodeSystem/accessibility'
end
