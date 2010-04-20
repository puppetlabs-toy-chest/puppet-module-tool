desc "Setup application's directories and configurations"
task :setup do
  # Create transient directories
  [
    File.join(RAILS_ROOT, "log"),
    File.join(RAILS_ROOT, "tmp"),
  ].each do |directory|
    mkdir_p directory unless File.exist?(directory)
  end

  # Copy sample configuration files into place
  [
    "config/database~sample.yml",
    "spec/spec~sample.opts",
    "spec/rcov~sample.opts",
  ].each do |filename|
    source = File.join(RAILS_ROOT, filename)
    target = File.join(RAILS_ROOT, filename.sub(/~sample/, ""))
    cp(source, target) unless File.exist?(target)
  end
end
