require 'csv'
require 'optparse'
require 'rexml/document'

option = {}
option_parser = OptionParser.new do |op|
    op.banner = "Usage: #{$0} [options] [medical expenses notification data file...]"
    op.on('-o PATH', '--output', 'output file path') do |v|
        option[:output] = v
    end
end
option_parser.parse!(ARGV)

io = option[:output].nil? ? IO.open($stdout.fileno, 'wb') : File.open(option[:output], 'wb')
CSV.instance(io, write_headers: true, headers: %w(patient_name year_of_issue month_of_issue hospital_name medical_consultation_fee)) do |csv_writer|
    ARGV.each do |path|
        medical_expenses_notification_data_xml_document = REXML::Document.new(File.new(path))
        medical_expenses_notification_data_xml_document.elements.each('/TEG700/WBD00000/WBD00010') do |medical_expenses_element|
            csv_writer << [
                medical_expenses_element.elements['WBD00020'].text,
                medical_expenses_element.elements['WBD00030/gen:yyyy'].text,
                medical_expenses_element.elements['WBD00030/gen:mm'].text,
                medical_expenses_element.elements['WBD00040'].text,
                medical_expenses_element.elements['WBD00050'].text,
            ]
        end
    end
end
io.close()
