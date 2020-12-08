require 'json'
require 'pry'
    indir = ARGV[0]   # point to output directory
    
    ndouts = []
    Dir.glob("#{indir}/*") do |typedir|
        puts "working on input directory: #{typedir}..."
        resourceType = File.basename(typedir)
        outfile = "#{resourceType}.ndjson"
        ndouts << {
            "type" => resourceType,
            "url" => outfile
        }
        outfile = "#{resourceType}.ndjson"
        puts "writing to #{outfile}"
        o = File.open(outfile,"w")
        Dir.glob("#{typedir}/*.json") do |jsonfile|
            puts "working on: #{jsonfile}..."
            s = File.read(jsonfile)
            h = JSON.parse(s)
            o.puts(JSON.generate(h))
        end
        o.close
    end
    output = {
        "transactionTime" => Time.now.strftime("%d/%m/%Y %H:%M"),
        "request" => "<baseFhirURL>/$export",
        "requiresAccessToken" => false,
        "output" => ndouts,
        "error" => { "type" => "OperationOutcome",
                    "url" =>  "http://serverpath2/err_file_1.ndjson"}
    }
    export = File.open("export.json","w")
    export.write(JSON.pretty_generate(output))
 
