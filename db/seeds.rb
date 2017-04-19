# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "csv"

CSV.foreach('db/postal.csv', headers: true, row_sep: "\r\n", encoding: "SJIS") do |row|
  Postalcode.create(code: row[0], city: row[1], address: row[2])
end
