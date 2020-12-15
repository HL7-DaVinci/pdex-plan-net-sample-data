require 'json'
require 'pry'

def create_bundle 
    bundle = {}
    bundle["entry"] = []
    bundle["resourceType"] = "Bundle"
    bundle["id"] = "bundle-transaction"
    bundle["type"] = "transaction"
    bundle
  end
    indir = ARGV[0]   # point to output directory
    
    Dir.glob("#{indir}/*") do |typedir|
        puts "working on input directory: #{typedir}..."
        resourceType = File.basename(typedir)
        outfile = "#{resourceType}-bundle.json"
        puts "writing to #{outfile}"
        o = File.open(outfile,"w")
        bundle = create_bundle
        Dir.glob("#{typedir}/*.json") do |jsonfile|
            puts "working on: #{jsonfile}..."
            s = File.read(jsonfile)
            resource = JSON.parse(s)
            entry = {}
            resourceId = resource["resourceType"] + "/" + resource["id"]
            entry["resource"] = resource 
            entry["request"] =  {
            "method" => "PUT",
            "url" => resourceId
            }
            bundle["entry"] << entry
        end
        o.write(JSON.pretty_generate(bundle))
        o.close
    end

    