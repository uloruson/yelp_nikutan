require "csv"

CSV.open('db/postal.csv', :row_sep => :auto, :col_sep => "," , encoding: 'Shift_JIS:UTF-8') do |csv|
    csv.each { |row| Postalcode.create(code: row[0], city: row[1], address: row[2]) }
end
