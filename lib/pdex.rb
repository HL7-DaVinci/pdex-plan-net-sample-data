require 'active_support'
require 'active_support/core_ext/object'

module PDEX
  ENDPOINT_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-endpoint'
  HEALTHCARE_SERVICE_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-healthcareservice'
  INSURANCE_PLAN_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-insuranceplan'
  NETWORK_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-network'
  PRACTITIONER_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-practitioner'
  PRACTITIONER_ROLE_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-practitionerrole'
  ORGANIZATION_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-organization'
  ORGANIZATION_AFFILIATION_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-organizationaffiliation'
  LOCATION_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-location'

  ACCESSIBILITY_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/accessibility'
  CONTACT_POINT_AVAILABLE_TIME_EXTENSION_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/contactpoint-availabletime'
  ENDPOINT_USE_CASE_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/endpoint-usecase'
  NEW_PATIENTS_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/newpatients'
  NEW_PATIENT_PROFILE_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/newpatientprofile'
  PRACTITIONER_QUALIFICATION_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/practitioner-qualification'

  ACCESSIBILITY_CODE_SYSTEM_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/CodeSystem/accessibility'
  ENDPOINT_USE_CASE_SYSTEM_URL = 'http://hl7.org/fhir/uv/vhdir/CodeSystem/usecase'
  PAYER_CHARACTERISTICS_CODE_SYSTEM_URL = 'http://hl7.org/fhir/uv/vhdir/CodeSystem/payercharacteristics'
end
