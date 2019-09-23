require 'csv'
require 'pry'
require_relative 'lib/pdex'

PDEX::NPPESDataLoader.load

PDEX::FHIRGenerator.generate
