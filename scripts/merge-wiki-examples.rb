require "json"

def usable?(text, word)
  return false if text.nil?
  text = text.strip
  return false if text.length < 20 || text.length > 180
  return false if text.match?(/\b(thou|thee|hath|doth|thy|ye)\b/i)
  return false if text.count('"') > 2 || text.include?("\\")
  text.match?(/\b#{Regexp.escape(word)}(?:s|es|ed|ing|er|ly)?\b/i)
end

best = {}
File.foreach("/tmp/wiki-examples.tsv") do |line|
  word, text = line.chomp.split("\t", 2)
  next unless usable?(text, word)
  current = best[word]
  best[word] = text.strip if current.nil? || text.length < current.length
end

path = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content/vocab.json"
data = JSON.parse(File.read(path))
filled = 0
samples = []
data["words"].each do |item|
  next unless item["exampleEn"].to_s.strip.empty?
  text = best[item["word"].downcase]
  next if text.nil?
  item["exampleEn"] = text
  item["exampleVi"] = ""
  filled += 1
  samples << "#{item["word"]}: #{text}" if samples.size < 8
end
missing = data["words"].count { |item| item["exampleEn"].to_s.strip.empty? }
File.write(path, JSON.pretty_generate(data) + "\n")
puts "wiki_choices=#{best.size} filled=#{filled} still_missing=#{missing}"
puts samples.join("\n")
