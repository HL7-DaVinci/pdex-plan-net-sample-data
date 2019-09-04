require 'active_support'
require 'active_support/core_ext/object'

module PDEX
  ENDPOINT_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Endpoint'
  HEALTHCARE_SERVICE_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-HealthcareService'
  INSURANCE_PLAN_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-InsurancePlan'
  NETWORK_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Network'
  PRACTITIONER_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Practitioner'
  PRACTITIONER_ROLE_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-PractitionerRole'
  ORGANIZATION_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Organization'
  ORGANIZATION_AFFILIATION_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-OrganizationAffiliation'
  LOCATION_PROFILE_URL = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/StructureDefinition/plannet-Location'

  ACCESSIBILITY_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/accessibility'
  COMMUNICATION_PROFICIENCY_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/communication-proficiency'
  CONTACT_POINT_AVAILABLE_TIME_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/contactpoint-availabletime'
  ENDPOINT_USE_CASE_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/endpoint-usecase'
  NETWORK_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/network-reference'
  NEW_PATIENTS_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/newpatients'
  NEW_PATIENT_PROFILE_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/newpatientprofile'
  PRACTITIONER_QUALIFICATION_EXTENSION_URL = 'http://hl7.org/fhir/uv/vhdir/StructureDefinition/practitioner-qualification'

  ACCESSIBILITY_CODE_SYSTEM_URL = 'http://hl7.org/fhir/uv/vhdir/CodeSystem/accessibility'
  COMMUNICATION_PROFICIENCY_SYSTEM_URL = 'http://hl7.org/fhir/uv/vhdir/CodeSystem/languageproficiency'
  ENDPOINT_USE_CASE_SYSTEM_URL = 'http://hl7.org/fhir/uv/vhdir/CodeSystem/usecase'
  PAYER_CHARACTERISTICS_CODE_SYSTEM_URL = 'http://hl7.org/fhir/uv/vhdir/CodeSystem/payercharacteristics'
end
