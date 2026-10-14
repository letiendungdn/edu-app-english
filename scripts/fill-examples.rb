require "json"

en_lines = File.readlines("/tmp/tatoeba-en-vi/Tatoeba.en-vi.en", chomp: true)
vi_lines = File.readlines("/tmp/tatoeba-en-vi/Tatoeba.en-vi.vi", chomp: true)
index = Hash.new { |hash, key| hash[key] = [] }
pairs = []

en_lines.each_with_index do |english, i|
  vietnamese = vi_lines[i].to_s.strip
  english = english.to_s.strip
  next if english.length < 12 || english.length > 220 || vietnamese.empty? || vietnamese.length > 220
  tokens = english.downcase.scan(/[a-z]+(?:'[a-z]+)?/)
  next if tokens.size < 3 || tokens.size > 18
  id = pairs.size
  pairs << [english, vietnamese]
  tokens.uniq.each do |token|
    list = index[token]
    list << id if list.size < 12
  end
end

path = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content/vocab.json"
data = JSON.parse(File.read(path))
filled = 0
missed = 0

data["words"].each do |item|
  next unless item["exampleEn"].to_s.strip.empty?
  word = item["word"].to_s.strip.downcase
  next if word.empty?
  tokens = word.scan(/[a-z]+(?:'[a-z]+)?/)
  if tokens.empty?
    missed += 1
    next
  end
  pattern = /\b#{Regexp.escape(word)}\b/i
  candidate_ids = index[tokens.first] || []
  chosen = nil
  candidate_ids.each do |id|
    english, vietnamese = pairs[id]
    next unless english.match?(pattern)
    chosen = [english, vietnamese] if chosen.nil? || english.length < chosen[0].length
  end
  if chosen.nil?
    missed += 1
    next
  end
  item["exampleEn"] = chosen[0]
  item["exampleVi"] = chosen[1]
  filled += 1
end

File.write(path, JSON.pretty_generate(data) + "\n")
puts "pairs=#{pairs.size} filled=#{filled} still_missing=#{missed} words=#{data["words"].size}"
