require "json"

root = "/Users/dung/Projects/edu-app-english"
path = "#{root}/backend/src/main/resources/content/vocab.json"
data = JSON.parse(File.read(path))
known = {}
data["words"].each { |word| known[word["word"].downcase] = true }
sort_order = data["words"].map { |word| word["sortOrder"] }.max || 0

parts_of_speech = %w[noun verb adjective adverb preposition conjunction pronoun interjection phrase phrasal_verb]
levels = %w[A1 A2 B1 B2 C1 C2]
icons = {
  "Clothes" => "👕",
  "City & Transport" => "🚌",
  "Home" => "🏡",
  "Feelings" => "😊",
  "Sports" => "⚽",
  "Communication" => "💬",
  "Society" => "🏛️"
}

added = 0
errors = []

Dir["#{root}/scripts/lexicon/*.tsv"].sort.each do |file|
  File.readlines(file, chomp: true).each_with_index do |line, index|
    next if line.strip.empty?
    fields = line.split("\t", -1)
    next if fields.any? { |field| field == "SKIP" }
    if fields.size != 7
      errors << "#{File.basename(file)}:#{index + 1} có #{fields.size} cột"
      next
    end
    topic, level, word, pos, meaning, example_en, example_vi = fields
    next if fields.any? { |field| field == "SKIP" || field.strip.empty? }
    key = word.downcase
    next if known[key]
    unless parts_of_speech.include?(pos) && levels.include?(level)
      errors << "#{word}: loại từ hoặc cấp không hợp lệ (#{pos}, #{level})"
      next
    end
    if [word, meaning, example_en, example_vi].any? { |field| field.length > 250 }
      errors << "#{word}: một trường dài quá 250 ký tự"
      next
    end
    sort_order += 1
    known[key] = true
    data["words"] << {
      "topic" => topic,
      "word" => word,
      "phonetic" => "",
      "meaningVi" => meaning,
      "level" => level,
      "partOfSpeech" => pos,
      "exampleEn" => example_en,
      "exampleVi" => example_vi,
      "sortOrder" => sort_order
    }
    added += 1
    next if data["topics"].any? { |item| item["name"] == topic }
    data["topics"] << {
      "name" => topic,
      "icon" => icons.fetch(topic, "📘"),
      "sortOrder" => data["topics"].size + 1
    }
  end
end

if errors.any?
  warn "ERRORS #{errors.size}"
  errors.first(40).each { |error| warn error }
  exit 1
end

File.write(path, JSON.pretty_generate(data) + "\n")
counts = data["words"].group_by { |word| word["level"] }
puts "added=#{added} total=#{data["words"].size} topics=#{data["topics"].size}"
counts.sort.each { |level, words| puts "#{level}=#{words.size}" }
