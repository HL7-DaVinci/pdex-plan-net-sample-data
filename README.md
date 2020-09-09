# Da Vinci Plan-Net Resources

This project uses freely available NPPES data to create FHIR resources based on the proposed
Da Vinci Plan Network IG.  

## Generating resources

Run the following commands to generate the sample resources:
```
bundle install
bundle exec ruby generate.rb
```

## Code Organization

The code in this repo is largely organized in three layers:

- `nppes_*.rb` - These classes parse NPPES data from .csv files and expose the
  data through a public interface.
- `*_factory.rb` - These classes use one of the NPPES data classes (and perhaps
  some other data) to generate one of the Plan-Net FHIR resources.
- `*_generator.rb` - These classes handle passing the required NPPES data to the
  factories and writing the resulting FHIR resources to disk.
  
Additionally, `nppes_data_loader` and `nppes_data_repo` are responsible for
loading the NPPES data into memory and making the data accessible to the
factories and generators.

## Acknowledgement
This Ruby package was inspired by the Python [VhDir sample generation code](https://github.com/HL7/VhDir/tree/master/notes_and_tools/example-generation) package developed by Eric Haas et al, an uses the same [NPPES extract](https://github.com/HL7/VhDir/tree/master/notes_and_tools/example-generation/sample-nppes-data) as source data.

## License

Copyright 2020 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
