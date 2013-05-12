require 'bundler'
Bundler.require

require './src/models'

require 'csv'

task :users_from_csv do
  if ENV['csv'].nil?
    raise "PLEASE PROVIDE A CSV FILE with `csv=path_to_file.csv`"
  end

  if !ENV['year'].nil? && ENV['year'].to_i < 1965
    raise "year= must be a 4 digit number designating a year after ITP was founded."
  end

  begin
    csv = CSV.read ENV['csv']

    csv.each do |row|
      # If year was specified, skip rows that don't match the year.
      if !ENV['year'].nil?
        next if row.last.to_i != ENV['year'].to_i
      end

      user = User.create(
        netid: row[0],
        first_name: row[3],
        last_name: row[2],
        year: row.last.to_i
      )
    end
  rescue
    raise "There was a problem loading the csv you specified."
  end
end

task :summary do
  @sections = Section.all

  text = []

  @sections.each do |section|
    text << "\n"
    text << "# #{section.name} - #{section.advisor}"
    text << "###################"

    section.students.each do |student|
      text << "\n"
      text << "#{student}"
      text << "#{student.thesis.title}"
      text << "#{student.thesis.elevator_pitch}"
      text << "#{student.thesis.link}"
    end
  end

  File.open('summary.txt', 'w') do |f|
    f.write text.join("\n")
  end
end