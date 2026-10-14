require "json"

dict = {}
File.foreach("/tmp/en_US_ipa.txt") do |line|
  word, ipa = line.strip.split("\t", 2)
  next if word.nil? || ipa.nil? || ipa.empty?
  first = ipa.split(",").first.to_s.strip
  next if first.empty? || first.length > 80
  dict[word.downcase] = first
end

path = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content/vocab.json"
data = JSON.parse(File.read(path))
filled = 0
already = 0
miss = []
data["words"].each do |item|
  if item["phonetic"].to_s.strip != ""
    already += 1
    next
  end
  key = item["word"].to_s.strip.downcase
  ipa = dict[key]
  if ipa
    item["phonetic"] = ipa
    filled += 1
  else
    miss << key
  end
end

File.write(path, JSON.pretty_generate(data) + "\n")
File.write("/tmp/ipa-miss.txt", miss.uniq.sort.join("\n") + "\n")
puts "filled=#{filled} already=#{already} miss=#{miss.uniq.size} words=#{data["words"].size}"
