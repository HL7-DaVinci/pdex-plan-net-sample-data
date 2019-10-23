require 'digest'

module PDEX
  module ShortName
    # Take pharmacy names from ct_pharmacies.csv and creates a short name that
    # represents a collection of similarly named pharmacies. For example, 'CVS
    # #38789' and 'CVS Pharmacy #8685' and 'CVS/Pharmacy #122' and 'CVS/Store
    # #444' all map to 'CVS'
    def short_name(name)
      name.gsub(/[,\/]/," ")
        .gsub("  "," ")
        .split('#').first
        .split(/STORE|SUPERMARKET|OF|PHARMACY/).first
        .rstrip
    end

    # Pharmacy orgs have unique hash index, so pharmacies can figure out their
    # managing Org by calling digest_name
    def digest_name(name)
      Digest::SHA2.hexdigest(short_name(name))[0..24]
    end

    # Pharmacy orgs can figure out their unique name by calling
    # digest_short_name
    def digest_short_name(name)
      Digest::SHA2.hexdigest(name)[0..24]
    end
  end
end
