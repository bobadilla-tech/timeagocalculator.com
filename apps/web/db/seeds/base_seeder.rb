class BaseSeeder
  def self.run
    new.run
  end

  protected

  def data_path(filename)
    Rails.root.join("db/seeds/data", filename)
  end

  def load_json(filename)
    JSON.parse(File.read(data_path(filename)))
  end
end
