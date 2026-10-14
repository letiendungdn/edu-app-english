require "json"

ROOT = "/Users/dung/Projects/edu-app-english"
VOCAB = "#{ROOT}/backend/src/main/resources/content/vocab.json"

CEFR_POS = {
  "noun" => "noun",
  "verb" => "verb",
  "vern" => "verb",
  "adjective" => "adjective",
  "adverb" => "adverb",
  "preposition" => "preposition",
  "conjunction" => "conjunction",
  "pronoun" => "pronoun",
  "interjection" => "interjection",
  "number" => "noun",
  "modal auxiliary" => "verb",
  "be-verb" => "verb",
  "do-verb" => "verb",
  "have-verb" => "verb"
}.freeze

WIKI_POS = {
  "n" => "noun",
  "v" => "verb",
  "adj" => "adjective",
  "adv" => "adverb",
  "prep" => "preposition",
  "conj" => "conjunction",
  "pron" => "pronoun",
  "interj" => "interjection",
  "num" => "noun"
}.freeze

LEVEL_RANK = { "A1" => 1, "A2" => 2, "B1" => 3, "B2" => 4, "C1" => 5, "C2" => 6 }.freeze

TOPIC_BY_CATEGORY = {
  "Work and Jobs" => "Work & Career",
  "Work and jobs" => "Work & Career",
  "Education" => "Education",
  "Objects and rooms" => "Home",
  "News, lifestyles and current affairs" => "Society",
  "Things in the town, shops and shopping" => "Shopping",
  "Food and drink" => "Food",
  "Travel and services vocab" => "Travel",
  "Hobbies and pastimes" => "Sports",
  "Family life" => "Family",
  "Nationalities and countries" => "Society",
  "Clothes" => "Clothes",
  "Leisure activities" => "Daily Life",
  "Books and literature" => "Communication",
  "Media" => "Communication",
  "Shopping" => "Shopping",
  "Personal information" => "Daily Life",
  "Ways of travelling" => "City & Transport",
  "Arts" => "Society",
  "Colours" => "Daily Life",
  "Technical and legal language" => "Academic",
  "Holidays" => "Daily Life",
  "Film" => "Communication",
  "Scientific development" => "Academic",
  "Dimensions" => "Daily Life",
  "Adjectives: personality, description, feelings" => "Feelings",
  "Hobbies and lifestyles" => "Daily Life"
}.freeze

def parse_csv_line(line)
  fields = []
  cur = +""
  quoted = false
  i = 0
  while i < line.length
    char = line[i]
    if quoted
      if char == '"'
        if line[i + 1] == '"'
          cur << '"'
          i += 1
        else
          quoted = false
        end
      else
        cur << char
      end
    elsif char == '"'
      quoted = true
    elsif char == ","
      fields << cur
      cur = +""
    else
      cur << char
    end
    i += 1
  end
  fields << cur
  fields
end

def clean_meaning(text)
  meaning = text.to_s.gsub(/\s+/, " ").strip
  meaning = meaning.gsub(%r{\A/+|/+\z}, "").strip
  return nil if meaning.empty? || meaning.length < 1
  return nil if meaning.include?("<") || meaning.include?("{") || meaning.include?("http")
  return nil unless meaning.match?(/[[:alpha:]]/)
  if meaning.length > 240
    cut = meaning[0, 240]
    comma = cut.rindex(",")
    meaning = comma && comma > 40 ? cut[0, comma] : cut
  end
  meaning
end

def vietnamese?(text, word)
  return false if text.nil? || text.empty?
  return false if text.casecmp?(word)
  return true if text.match?(/[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i)
  return false if text.match?(/\b(the|of|and|to|for|with|from|that|which|someone|something)\b/i)
  text.length <= 48
end

def load_wiktionary
  by_word = Hash.new { |hash, key| hash[key] = {} }
  File.foreach("/tmp/en-vi-wiktionary.txt") do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")
    match = line.match(/\A(.+?) \{([^}]+)\}(?: \([^)]*\))? :: (.+)\z/)
    next unless match
    word = match[1].strip.downcase
    pos = WIKI_POS[match[2].strip]
    meaning = clean_meaning(match[3])
    next if pos.nil? || !vietnamese?(meaning, word)
    bucket = by_word[word][pos] ||= []
    bucket << meaning unless bucket.include?(meaning)
  end
  by_word
end

def remember_reverse(by_word, word, meaning)
  word = word.to_s.strip.downcase.sub(/\Ato /, "")
  return unless word.match?(/\A[a-z][a-z' -]{0,40}\z/)
  return if word.split.size > 3
  meaning = clean_meaning(meaning)
  return unless vietnamese?(meaning, word)
  by_word[word][:any] ||= []
  list = by_word[word][:any]
  list << meaning unless list.include?(meaning) || list.size >= 2
end

def load_reverse(by_word)
  File.foreach("/tmp/vi2enwikitxt.txt") do |line|
    vietnamese, english, = line.split("\t", 3)
    next if vietnamese.nil? || english.nil?
    next if vietnamese.start_with?("-")
    next if vietnamese.match?(/\d/)
    english = english.gsub(%r{<br\s*/?>}i, " ").gsub(/<[^>]+>/, " ")
    english.split(/\d+\.\s*/).each do |sense|
      sense = sense.sub(/\A\([^)]*\)\s*/, "")
      sense = sense.split(/[();]/).first.to_s.strip
      sense = sense.sub(/\Ato /, "")
      remember_reverse(by_word, sense, vietnamese)
    end
  end
end

def meaning_for(by_word, word, pos)
  entry = by_word[word.downcase]
  return nil if entry.nil?
  parts = entry[pos] || entry[:any] || entry.values.flatten
  parts = Array(parts).flatten.uniq
  return nil if parts.empty?
  text = parts.first(3).join(", ")
  text = text[0, 240].sub(/,\s*\z/, "")
  vietnamese?(text, word) ? text : nil
end

def headwords(raw)
  raw.to_s.strip.split("/").map(&:strip).reject(&:empty?)
end

def acceptable_headword(word)
  return false if word.nil? || word.empty?
  return false if word.match?(/[0-9.\/]/)
  return false if word.length > 40
  return false unless word.match?(/\A[A-Za-z][A-Za-z' -]*\z/)
  word.split.size <= 3
end

def app_pos(raw_pos, word)
  pos = CEFR_POS[raw_pos.to_s.strip]
  return nil if pos.nil?
  return "phrasal_verb" if pos == "verb" && word.include?(" ")
  return "phrase" if word.include?(" ") && pos != "phrasal_verb"
  pos
end

def load_ipa
  ipa = {}
  return ipa unless File.exist?("/tmp/en_US_ipa.txt")
  File.foreach("/tmp/en_US_ipa.txt") do |line|
    word, pronunciation = line.strip.split("\t", 2)
    next if word.nil? || pronunciation.nil?
    first = pronunciation.split(",").first.to_s.strip
    next if first.empty? || first.length > 80
    ipa[word.downcase] ||= first
  end
  ipa
end

def read_level_rows(path, category_index)
  rows = []
  File.readlines(path, chomp: true).drop(1).each do |line|
    fields = parse_csv_line(line)
    headwords(fields[0]).each do |word|
      next unless acceptable_headword(word)
      pos = app_pos(fields[1], word)
      level = fields[2].to_s.strip
      next if pos.nil? || !LEVEL_RANK.key?(level)
      category = category_index ? fields[category_index].to_s.strip : ""
      rows << { "word" => word, "pos" => pos, "level" => level, "category" => category }
    end
  end
  rows
end

glosses = load_wiktionary
load_reverse(glosses)
ipa = load_ipa
rows = read_level_rows("/tmp/cefrj.csv", 3) + read_level_rows("/tmp/octanove-c1c2.csv", nil)

KAIKKI_POS = {
  "noun" => "noun",
  "verb" => "verb",
  "adj" => "adjective",
  "adv" => "adverb",
  "prep" => "preposition",
  "conj" => "conjunction",
  "pron" => "pronoun",
  "intj" => "interjection",
  "num" => "noun",
  "aux" => "verb",
  "particle" => "adverb",
  "phrase" => "phrase"
}.freeze

def level_for_rank(rank)
  return "A1" if rank <= 800
  return "A2" if rank <= 2000
  return "B1" if rank <= 4000
  return "B2" if rank <= 8000
  return "C1" if rank <= 14000
  "C2"
end

def kaikki_meaning(kaikki, word, pos)
  entry = kaikki[word]
  return nil if entry.nil? || entry.empty?
  entry[pos] || entry.values.first
end

kaikki = Hash.new { |hash, key| hash[key] = {} }
if File.exist?("/tmp/en-vi-kaikki.tsv")
  File.foreach("/tmp/en-vi-kaikki.tsv") do |line|
    word, pos, meaning = line.chomp.split("\t", 3)
    app_pos = KAIKKI_POS[pos]
    next if word.nil? || app_pos.nil? || meaning.nil? || meaning.empty?
    kaikki[word][app_pos] ||= meaning
  end
end

best = {}
rows.each do |row|
  key = row["word"].downcase
  current = best[key]
  if current.nil? || LEVEL_RANK[row["level"]] < LEVEL_RANK[current["level"]]
    best[key] = row
  end
end

rank = 0
File.foreach("/tmp/en_50k.txt") do |line|
  word, = line.strip.split(" ", 2)
  rank += 1
  break if rank > 30000
  key = word.to_s.downcase
  next if best[key] || kaikki[key].empty?
  next unless key.match?(/\A[a-z][a-z'-]{2,}\z/)
  best[key] = {
    "word" => key,
    "pos" => kaikki[key].keys.first,
    "level" => level_for_rank(rank),
    "category" => ""
  }
end

data = JSON.parse(File.read(VOCAB))
known = {}
data["words"].each { |word| known[word["word"].downcase] = true }
sort_order = data["words"].map { |word| word["sortOrder"] }.max || 0
added = 0
with_ipa = 0
skipped_meaning = 0
cleaned = 0
samples = []

data["words"].each do |item|
  next unless item["exampleEn"].to_s.empty? && item["exampleVi"].to_s.empty?
  next if item["meaningVi"].to_s.count(",") < 3
  better = kaikki_meaning(kaikki, item["word"].downcase, item["partOfSpeech"])
  next if better.nil? || better.length >= item["meaningVi"].to_s.length
  item["meaningVi"] = better
  cleaned += 1
end

best.each_value do |row|
  key = row["word"].downcase
  if known[key]
    next
  end
  meaning = kaikki_meaning(kaikki, key, row["pos"]) || meaning_for(glosses, key, row["pos"])
  if meaning.nil? || meaning.length > 250
    skipped_meaning += 1
    next
  end
  topic = TOPIC_BY_CATEGORY[row["category"]] || "Core #{row["level"]}"
  sort_order += 1
  phonetic = ipa[key].to_s
  with_ipa += 1 unless phonetic.empty?
  data["words"] << {
    "topic" => topic,
    "word" => row["word"],
    "phonetic" => phonetic,
    "meaningVi" => meaning,
    "level" => row["level"],
    "partOfSpeech" => row["pos"],
    "exampleEn" => "",
    "exampleVi" => "",
    "sortOrder" => sort_order
  }
  known[key] = true
  added += 1
  samples << "#{row["level"]}\t#{row["word"]}\t#{row["pos"]}\t#{meaning}" if samples.size < 12
  next if data["topics"].any? { |item| item["name"] == topic }
  data["topics"] << {
    "name" => topic,
    "icon" => "📘",
    "sortOrder" => data["topics"].size + 1
  }
end

File.write(VOCAB, JSON.pretty_generate(data) + "\n")
counts = data["words"].group_by { |word| word["level"] }
puts "added=#{added} cleaned=#{cleaned} skipped_no_vi=#{skipped_meaning} with_ipa=#{with_ipa} kaikki=#{kaikki.size} total=#{data["words"].size}"
counts.sort.each { |level, words| puts "#{level}=#{words.size}" }
puts "topics=#{data["topics"].map { |topic| topic["name"] }.join(", ")}"
puts samples.join("\n")
