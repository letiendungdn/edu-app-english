# frozen_string_literal: true

require "digest"
require "json"

PATH = "backend/src/main/resources/content/vocab.json"

def gloss(meaning)
  text = meaning.to_s.gsub(/\[[^\]]*\]/, " ").gsub(/\([^)]*\)/, " ").gsub(/\s+/, " ").strip
  parts = text.split(/[,;\/|]/).map(&:strip).reject(&:empty?)
  chosen = parts.find { |piece| piece.match?(/[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i) }
  chosen ||= parts.find { |piece| piece.length.between?(1, 24) }
  return nil if chosen.nil?

  chosen = chosen.gsub(/[^\p{L}\p{M}\s\-]/u, "").gsub(/\s+/, " ").strip
  words = chosen.split
  while chosen.length > 28 && words.size > 1
    words.pop
    chosen = words.join(" ")
  end
  return nil if chosen.empty? || chosen.length > 28

  chosen
end

def article(word)
  w = word.downcase
  return "an" if w.match?(/\A(hour|honest|honour|honor|heir)/)
  return "a" if w.match?(/\A(uni|eu|one|use|ufo)/)

  w.match?(/\A[aeiou]/) ? "an" : "a"
end

def mass?(word)
  word.match?(/(?:tion|sion|ment|ness|ity|ance|ence|ism|ship|ware)\z/i)
end

def formula?(text)
  return false if text.nil? || text.empty?
  return true if text.end_with?(" in the story.", " comes up in this lesson.", " lives near the market.")
  return true if text.include?(" is the main character.")
  return true if text.start_with?("We need to ") && text.end_with?(" before the test.")
  return true if text.start_with?("She tried to ") && text.end_with?(" during the exercise.")
  return true if text.start_with?("The path goes ") && text.end_with?(" the park.")
  return true if text.start_with?("Stay here ") && text.end_with?(" wait for me.")
  return true if text.start_with?("In the dialogue, ") && text.end_with?(" the speaker.")
  [
    "She pointed at the ", "His answer seemed ", "It is possible to ", "She answered ",
    "Please remember the words ", "The number ", "He said, ", "It was city ",
    "The teacher pointed out ", "I looked up ", "My notes include ", "We practised the word ",
    "Can you use ", "Today's class looks at ", "She wrote one sentence about ",
    "The reading mentions ", "Learners practise how to ", "He asked us to ",
    "The answer sounds ", "That idea seems ", "The ending felt ",
    "People described the place as ", "He explained the point ", "They finished the task ",
    "Someone called out ", "The lesson uses the phrase ", "Learners say the number ",
    "After class, I read a page about ", "My sister mentioned ", "We passed ",
    "The photo on the desk shows ", "He added ", "Children in the story find ",
    "She kept ", "A visitor asked the name of the ", "I called my ",
    "The class spent ten minutes on ", "I heard a short talk about ",
    "Our teacher gave an example of ", "People in the group asked about ",
    "The morning felt ", "Everyone said the result was ", "Her reply sounded ",
    "The street looked ", "I hope to ", "She managed to ", "They still need time to ",
    "He promised to ", "She explained the rule ", "He closed the door ",
    "They walked home ", "From the kitchen, someone shouted ", "The cat slipped ",
    "Wait here ", "The guide used the phrase ", "I had lunch with my "
  ].any? { |prefix| text.start_with?(prefix) }
end

PEOPLE = [
  ["Lan", "Lan"],
  ["Minh", "Minh"],
  ["My aunt", "Dì tôi"],
  ["The nurse", "Y tá"],
  ["A tourist", "Một du khách"],
  ["Our neighbour", "Hàng xóm"],
  ["The librarian", "Thủ thư"],
  ["My cousin", "Anh họ tôi"]
].freeze
TIMES = [
  ["this morning", "Sáng nay"],
  ["yesterday", "Hôm qua"],
  ["last Tuesday", "Thứ Ba tuần trước"],
  ["after lunch", "Sau bữa trưa"],
  ["on Saturday", "Thứ Bảy"],
  ["before the meeting", "Trước cuộc họp"]
].freeze
PLACES = [
  ["at the market", "ở chợ"],
  ["on the bus", "trên xe buýt"],
  ["in the classroom", "trong lớp"],
  ["at the clinic", "ở phòng khám"],
  ["in the park", "trong công viên"],
  ["at home", "ở nhà"]
].freeze
NOUN_VERBS = [
  ["talked about", "nói về"],
  ["asked about", "hỏi về"],
  ["read about", "đọc về"],
  ["heard about", "nghe về"]
].freeze
ADJ_NOUNS = [
  ["the street", "Con đường"],
  ["the room", "Căn phòng"],
  ["the answer", "Câu trả lời"],
  ["the plan", "Kế hoạch"],
  ["her voice", "Giọng cô ấy"],
  ["the soup", "Món súp"]
].freeze
ADJ_VERBS = [
  ["looked", "trông"],
  ["seemed", "có vẻ"],
  ["sounded", "nghe"]
].freeze
VERB_WRAPS = [
  ["decided to", "quyết định"],
  ["wanted to", "muốn"],
  ["learned to", "học cách"],
  ["forgot to", "quên"]
].freeze

def pick(word, list, shift)
  n = Digest::MD5.hexdigest("#{shift}:#{word}").to_i(16)
  list[n % list.size]
end

def cap(text)
  return text if text.nil? || text.empty?

  text[0].upcase + text[1..]
end

def pair(word, pos, vi)
  person, person_vi = pick(word, PEOPLE, "p")
  time, time_vi = pick(word, TIMES, "t")
  place, place_vi = pick(word, PLACES, "l")
  art = article(word)
  case pos
  when "noun"
    verb, verb_vi = pick(word, NOUN_VERBS, "v")
    noun = mass?(word) ? word : "#{art} #{word}"
    unit = mass?(word) ? vi : "một #{vi}"
    [
      "#{person} #{verb} #{noun} #{place} #{time}.",
      "#{time_vi}, #{person_vi} #{verb_vi} #{unit} #{place_vi}."
    ]
  when "adjective"
    thing, thing_vi = pick(word, ADJ_NOUNS, "n")
    verb, verb_vi = pick(word, ADJ_VERBS, "av")
      [
      "#{cap(time)}, #{thing} #{verb} #{word} #{place}.",
      "#{time_vi}, #{thing_vi.downcase} #{verb_vi} #{vi} #{place_vi}."
    ]
  when "verb"
    wrap, wrap_vi = pick(word, VERB_WRAPS, "w")
    [
      "#{person} #{wrap} #{word} #{time}.",
      "#{time_vi}, #{person_vi} #{wrap_vi} #{vi}."
    ]
  when "adverb"
    [
      "#{person} replied #{word} #{place} #{time}.",
      "#{time_vi}, #{person_vi} trả lời #{vi} #{place_vi}."
    ]
  when "interjection"
    [
      "#{time.capitalize}, #{person} called out \"#{cap(word)}!\" #{place}.",
      "#{time_vi}, #{person_vi} kêu \"#{cap(vi)}!\" #{place_vi}."
    ]
  when "preposition"
    [
      "The path runs #{word} the park #{time}.",
      "#{time_vi}, con đường chạy #{vi} công viên."
    ]
  when "conjunction"
    [
      "Stay in the classroom #{word} the bell rings.",
      "Ở lại trong lớp #{vi} chuông kêu."
    ]
  when "pronoun"
    [
      "In the dialogue, #{word} refers to #{person} #{time}.",
      "#{time_vi}, trong hội thoại, #{vi} chỉ #{person_vi}."
    ]
  else
    [
      "#{person} used the phrase \"#{word}\" #{place} #{time}.",
      "#{time_vi}, #{person_vi} dùng cụm \"#{vi}\" #{place_vi}."
    ]
  end
end

data = JSON.parse(File.read(PATH))
changed = 0
skipped = 0
openings = Hash.new(0)
data["words"].each do |item|
  en = item["exampleEn"].to_s.strip
  next unless formula?(en)

  vi = gloss(item["meaningVi"])
  if vi.nil?
    skipped += 1
    next
  end
  new_en, new_vi = pair(item["word"], item["partOfSpeech"], vi)
  if new_en.length > 255 || new_vi.length > 255 || formula?(new_en)
    skipped += 1
    warn "bad #{item["word"]}: #{new_en}"
    next
  end
  item["exampleEn"] = new_en
  item["exampleVi"] = new_vi
  changed += 1
  openings[new_en.split.first(3).join(" ")] += 1
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
left = data["words"].count { |item| formula?(item["exampleEn"].to_s) }
puts "changed=#{changed} skipped=#{skipped} still=#{left} openings=#{openings.size} max=#{openings.values.max}"
%w[airplane negotiate bone volcano].each do |name|
  w = data["words"].find { |item| item["word"] == name }
  puts "#{name}: #{w["exampleEn"]} | #{w["exampleVi"]}"
end
