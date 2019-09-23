# Da Vinci Plan-Net Resources

This project uses NPPES data to create FHIR resources based on the proposed
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
