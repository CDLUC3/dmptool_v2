module DbToFixture

  TEMP_FIXTURE_PATH = Rails.root.join("test", "new_fixtures")

  def fixturize(model)
    Dir.mkdir(TEMP_FIXTURE_PATH) unless File.exists?(TEMP_FIXTURE_PATH)
    fname = model.table_name
    file_path = TEMP_FIXTURE_PATH.join(fname)
    File.open(file_path, 'w') do |f|
      model.all.each do |m|
        f.write(m.to_yaml)
      end
    end
  end

end