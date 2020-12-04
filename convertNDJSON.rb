require 'json'
require 'pry'
    indir = ARGV[0]   # point to output directory

    Dir.glob("#{indir}/*") do |typedir|
        puts "working on input directory: #{typedir}..."
        outfile = "#{File.basename(typedir)}.ndjson"
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
  