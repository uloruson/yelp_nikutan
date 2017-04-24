# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "csv"

CSV.open('db/postal.csv', :row_sep => :auto, :col_sep => ";" , encoding: 'Shift_JIS:UTF-8') do |csv|
    csv.each { |row| Postalcode.create(code: row[0], city: row[1], address: row[2]) }
end
