task default: [:start]

task :init do
  path = 'data'.freeze
  FileUtils.mkdir_p(path) unless FileTest.exist?(path)
  system 'bundle install --path vendor/bundle --without production'
end

task :test do
  Dir.glob('./test/*_test.rb').each do |test_file|
    system "bundle exec ruby #{test_file}"
  end
end

task :start do
  system 'bundle exec rackup -o 0.0.0.0 -p 9393'
end
