# NPPES to FHIR

This project uses NPPES data to create FHIR resources based on the proposed
Validated Healthcare Directory IG.

## Progress
- [x] Organization
  - [ ] `identifier.period` - is this really needed? hardcoded in python impl.
  - [ ] `partOf`
  - [ ] `endpoint`
- [x] Practitioner
  - [ ] `communication` - is this really needed? python impl. randomly chooses
        English or English and Spanish
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
- [ ] PractitionerRole
- [ ] Network
- [ ] InsurancePlan
- [ ] HealthcareService
- [ ] Endpoint
- [ ] Extension - Geolocation
- [ ] A script to put it all together and generate the resources
