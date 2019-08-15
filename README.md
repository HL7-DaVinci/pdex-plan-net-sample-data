# NPPES to FHIR

This project uses NPPES data to create FHIR resources based on the proposed
Validated Healthcare Directory IG.

## Progress
- [x] Organization
  - [ ] `partOf`
  - [ ] `endpoint`
- [x] Practitioner
  - [x] `communication`
  - [x] `communication` proficiency extension
  - [ ] `birthDate` - is this really needed? hardcoded in python impl.
- [x] Location
  - [ ] `network` extension in `newpatients` extension
  - [ ] `type` - is this really needed? python impl. questionable -- uses
        Practitioner specialty codes which don't fit with the extensibly bound
        VS
  - [ ] `position`
  - [ ] `endpoint`
- [x] OrganizationAffiliation
  - [ ] `endpoint`
  - [ ] `location`
  - [ ] `healthcareService`
- [x] PractitionerRole
  - [ ] `period` && `identifier.period`- is this really needed? hardcoded in python impl.
  - [ ] snomed codes for `code` and `specialty`
  - [ ] `healthcareService` - hcs code from nucc
  - [ ] `endpoint`
  - [ ] figure out what's going on with network PractitionerRoles in the python impl.
- [x] Network (this is an Organization profile, so it has the same issues)
  - [x] `partOf`
  - [ ] `endpoint`
- [x] InsurancePlan
  - [ ] How to represent an unlimited benefit?
- [x] HealthcareService
  - [x] new patients extension
  - [ ] ContactPoint availableTime
  - [ ] `endpoint`
- [x] Endpoint
  - [x] use case extension
  - [x] for Organizations
  - [ ] for Locations
  - [ ] for OrganizationAffiliations
  - [ ] for PractitionerRoles
  - [ ] for Networks
  - [ ] for HealthcareServices
  - [ ] `period` - is this really needed? hardcoded in python impl.
- [ ] Extension - Geolocation
  - [ ] get real lat/long
- [ ] A script to put it all together and actually generate the resources
