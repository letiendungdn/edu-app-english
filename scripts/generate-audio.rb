require "json"
require "fileutils"

root = "/Users/dung/Projects/edu-app-english"
json_path = "#{root}/backend/src/main/resources/content/listening.json"
media = "#{root}/backend/src/main/resources/media"
FileUtils.mkdir_p(media)
data = JSON.parse(File.read(json_path))

data["tracks"].each do |track|
  slug = track["title"].downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
  out = "#{media}/#{slug}.m4a"
  text_path = "/tmp/#{slug}.txt"
  File.write(text_path, track["transcript"].to_s)
  if !File.exist?(out) || File.size(out) < 1000
    ok = system("say", "-v", "Samantha", "-f", text_path, "-o", out)
    warn "say failed: #{track["title"]}" unless ok
  end
  track["audioUrl"] = "/api/media/#{slug}.m4a"
  puts "#{track["title"]} #{File.exist?(out) ? File.size(out) : 0}"
end

File.write(json_path, JSON.pretty_generate(data) + "\n")
puts "tracks=#{data["tracks"].size}"
