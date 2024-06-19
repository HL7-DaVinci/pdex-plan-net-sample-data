require "pry"
require "httparty"
require "tmpdir"
require "fileutils"
require "optparse"
require 'json'

# Retrieve options from command line arguments
options = OpenStruct.new
OptionParser.new do |opts|
  opts.on("-f", "--fhir_server FHIRSERVER", "The FHIR server to connect to") { |v| options.fhir_server = v }
end.parse!

# Read the const variables from options or set default value.
#FHIR_SERVER = options.fhir_server || "https://plan-net-ri.davinci.hl7.org/fhir"
FHIR_SERVER = options.fhir_server || "http://localhost:8080/fhir"
#CONFORMANCE_DEFINITIONS_URL = options.conformance_url || "https://build.fhir.org/ig/HL7/davinci-pdex-formulary/branches/master/definitions.json.zip"
FAILED_UPLOAD = []


def upload_sample_resources
  #location_file_path = File.join("location_resources", "*.json")
  file_path = [File.join("output", "Endpoint/*.json"), 
    File.join("output", "Location/*.json"), 
    File.join("output", "Organization/*.json"), 
    File.join("output", "InsurancePlan/*.json"), 
    File.join("output", "HealthcareService/*.json"), 
    File.join("output", "OrganizationAffiliation/*.json"), 
    File.join("output", "Practitioner/*.json"), 
    File.join("output", "PractitionerRole/*.json")
  ]
  
  #filenames = Dir.glob([file_path, location_file_path])
  filenames = Dir.glob(file_path)
  # .partition { |filename| filename.include? "InsurancePlan" }
  # .flatten
  puts "Uploading #{filenames.length} resources"
  filenames.each_with_index do |filename, index|
    resource = JSON.parse(File.read(filename), symbolize_names: true)
    puts "Writing " +  resource[:resourceType] + " - " + resource[:id]
     response = upload_resource(resource)
     FAILED_UPLOAD << resource unless response&.success?
     if index % 100 == 0
       puts "#{FAILED_UPLOAD.count} out of #{index + 1} attempted resources failed to be uploaded successfully."
     end
  end
end

def upload_resource(resource)
  resource_type = resource[:resourceType]
  id = resource[:id]
  begin
    HTTParty.put(
      "#{FHIR_SERVER}/#{resource_type}/#{id}",
      body: resource.to_json,
      headers: { 'Content-Type': "application/json" },
    )
  rescue => e
    puts "An exception occured when trying to load the resource #{resource[:resource_type]}/#{resource[:id]}."
    puts "Error#upload_resource: #{e.message}"
    return
  end
end

def retry_failed_upload
  n = FAILED_UPLOAD.size
  while !FAILED_UPLOAD.empty? && n > 0
    puts "#{FAILED_UPLOAD.count} resource(s) failed to upload. Retrying..."
    failed_upload_copy = FAILED_UPLOAD.dup
    FAILED_UPLOAD.clear
    failed_upload_copy.each do |resource|
      response = upload_resource(resource)
      FAILED_UPLOAD << resource unless response&.success?
    end
    n -= 1
  end
  puts "Ending the program ..."
  if FAILED_UPLOAD.empty?
    puts "All resources were uploaded successfully."
  else
    puts "#{FAILED_UPLOAD.count} resource(s) failed to upload"
  end
end

# Runs all the upload methods
def upload_all_resources
  #upload_conformance_resources
  upload_sample_resources
  retry_failed_upload
end

############## Running the upload methods #################
upload_all_resources
