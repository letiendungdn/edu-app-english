# frozen_string_literal: true

require "digest"
require "json"

PATH = "backend/src/main/resources/content/vocab.json"

PEOPLE = [
  ["Hien", "Hiền"], ["Tuan", "Tuấn"], ["Nga", "Nga"], ["Long", "Long"],
  ["Trang", "Trang"], ["Quan", "Quân"], ["Vy", "Vy"], ["Phu", "Phú"],
  ["Oanh", "Oanh"], ["Kiet", "Kiệt"], ["The receptionist", "Lễ tân"],
  ["The cyclist", "Người đi xe đạp"], ["The photographer", "Nhiếp ảnh"],
  ["The pharmacist", "Dược sĩ"], ["The carpenter", "Thợ mộc"],
  ["The firefighter", "Lính cứu hoả"], ["The pianist", "Nghệ sĩ piano"],
  ["The surgeon", "Bác sĩ phẫu thuật"], ["My colleague", "Đồng nghiệp"],
  ["The shopkeeper", "Chủ cửa hàng"], ["The scientist", "Nhà khoa học"],
  ["The artist", "Hoạ sĩ"], ["The cook", "Người nấu ăn"], ["The guard", "Bảo vệ"],
  ["The jeweller", "Thợ kim hoàn"], ["The optician", "Người đo mắt"],
  ["The ranger", "Kiểm lâm"], ["The florist", "Người bán hoa"],
  ["The porter", "Người khuân vác"], ["The tailor", "Thợ may"]
].freeze

PLACES = [
  ["beside the gate", "bên cổng"],
  ["near the bridge", "gần cây cầu"],
  ["inside the hall", "trong hội trường"],
  ["behind the library", "sau thư viện"],
  ["across the yard", "bên kia sân"],
  ["by the noticeboard", "cạnh bảng tin"],
  ["outside the clinic", "ngoài phòng khám"],
  ["along the footpath", "dọc lối đi"],
  ["next to the fountain", "cạnh đài phun nước"],
  ["in the courtyard", "trong sân trong"],
  ["under the awning", "dưới mái hiên"],
  ["at the bus stop", "ở trạm xe buýt"]
].freeze

TIMES = [
  ["on Wednesday", "Thứ Tư"],
  ["on Sunday", "Chủ Nhật"],
  ["last spring", "Mùa xuân năm ngoái"],
  ["this August", "Tháng Tám này"],
  ["after the lesson", "Sau tiết học"],
  ["before dark", "Trước khi tối"],
  ["in May", "Tháng Năm"],
  ["at dusk", "Lúc chạng vạng"],
  ["last July", "Tháng Bảy năm ngoái"],
  ["early in October", "Đầu tháng Mười"]
].freeze

NOUN_VERBS = [
  ["spotted", "thấy"],
  ["found", "thấy"],
  ["carried", "mang"],
  ["recorded", "ghi lại"],
  ["showed", "chỉ"],
  ["packed", "xếp"]
].freeze

WRAPS = [
  ["hopes to", "muốn"],
  ["refused to", "từ chối"],
  ["offered to", "nhận"],
  ["started to", "bắt đầu"]
].freeze

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

def one_token(text, prefix, suffix)
  return false unless text.start_with?(prefix) && text.end_with?(suffix)
  return false if text.length <= prefix.length + suffix.length

  mid = text[prefix.length...-suffix.length]
  !mid.strip.empty? && !mid.include?(" ")
end

def stock?(text)
  return false if text.nil? || text.empty?
  if (text.start_with?("I saw a ", "I saw an ") && text.end_with?(" this morning."))
    prefix = text.start_with?("I saw an ") ? "I saw an " : "I saw a "
    return one_token(text, prefix, " this morning.")
  end
  if (text.start_with?("She bought a ", "She bought an ") && text.end_with?(" yesterday."))
    prefix = text.start_with?("She bought an ") ? "She bought an " : "She bought a "
    return one_token(text, prefix, " yesterday.")
  end
  if (text.start_with?("We need a ", "We need an ") && text.end_with?(" for class."))
    prefix = text.start_with?("We need an ") ? "We need an " : "We need a "
    return one_token(text, prefix, " for class.")
  end
  return true if text.start_with?("We learned about ") && text.end_with?(" today.") && one_token(text, "We learned about ", " today.")

  [
    ["She asked about ", "."],
    ["The result was ", "."],
    ["Her answer was ", "."],
    ["They want to ", "."],
    ["She learned how to ", "."],
    ["We decided to ", "."]
  ].any? { |prefix, suffix| one_token(text, prefix, suffix) }
end

def pick(word, list, shift)
  n = Digest::MD5.hexdigest("#{shift}:#{word}").to_i(16)
  list[n % list.size]
end

def cap(text)
  return text if text.nil? || text.empty?

  text[0].upcase + text[1..]
end

def mid(person)
  return person if person.match?(/\A[A-Z][a-z]+\z/)

  person[0].downcase + person[1..]
end

def noun_phrase(word)
  mass?(word) ? word : "#{article(word)} #{word}"
end

def unit(word, vi)
  mass?(word) ? vi : "một #{vi}"
end

def pair(word, pos, vi)
  person, person_vi = pick(word, PEOPLE, "p2")
  place, place_vi = pick(word, PLACES, "l2")
  time, time_vi = pick(word, TIMES, "t2")
  who = mid(person)
  shown = cap(word)
  noun = noun_phrase(word)
  one = unit(word, vi)
  verb, verb_vi = pick(word, NOUN_VERBS, "nv2")
  wrap, wrap_vi = pick(word, WRAPS, "w2")
  case pos
  when "noun"
    ["#{person} #{verb} #{noun} #{place} #{time}.",
     "#{time_vi}, #{person_vi} #{verb_vi} #{one} #{place_vi}."]
  when "adjective"
    ["#{person} stayed #{word} #{place} #{time}.",
     "#{time_vi}, #{person_vi} vẫn #{vi} #{place_vi}."]
  when "verb", "phrasal_verb"
    ["#{person} #{wrap} #{word} #{place} #{time}.",
     "#{time_vi}, #{person_vi} #{wrap_vi} #{vi} #{place_vi}."]
  when "adverb"
    ["#{person} answered #{word} #{place} #{time}.",
     "#{time_vi}, #{person_vi} trả lời #{vi} #{place_vi}."]
  when "interjection"
    ["\"#{shown}!\" #{who} said #{place} #{time}.",
     "#{time_vi}, #{person_vi} nói \"#{cap(vi)}!\" #{place_vi}."]
  when "preposition"
    ["The lane runs #{word} the hill #{time}.",
     "#{time_vi}, con đường chạy #{vi} đồi."]
  when "conjunction"
    ["Call #{word} #{who} arrives #{time}.",
     "#{time_vi}, gọi #{vi} #{person_vi} tới."]
  when "pronoun"
    ["#{shown} stood beside #{who} #{time}.",
     "#{time_vi}, #{vi} đứng cạnh #{person_vi}."]
  else
    ["#{person} repeated \"#{word}\" #{time}.",
     "#{time_vi}, #{person_vi} nhắc lại \"#{vi}\"."]
  end
end

def blocked?(text)
  return true if stock?(text)
  return true if text.end_with?(" in the story.", " comes up in this lesson.", " lives near the market.")
  [
    "She pointed at the ", "After class, I read a page about ", "My sister mentioned ",
    "We passed ", "I saw a ", "I saw an ", "She bought a ", "She bought an ",
    "We need a ", "We need an ", "We learned about ", "She asked about ",
    "The result was ", "Her answer was ", "They want to ", "She learned how ",
    "We decided to ", "There is a ", "We need to ", "In the dialogue, "
  ].any? { |prefix| text.start_with?(prefix) }
end

data = JSON.parse(File.read(PATH))
changed = 0
skipped = 0
openings = Hash.new(0)
data["words"].each do |item|
  en = item["exampleEn"].to_s.strip
  next unless stock?(en)

  vi = gloss(item["meaningVi"])
  if vi.nil?
    skipped += 1
    next
  end
  new_en, new_vi = pair(item["word"], item["partOfSpeech"], vi)
  if new_en.length > 255 || new_vi.length > 255 || blocked?(new_en)
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
left = data["words"].count { |item| stock?(item["exampleEn"].to_s) }
top = openings.max_by { |_, count| count }
puts "changed=#{changed} skipped=#{skipped} still=#{left} openings=#{openings.size} max=#{openings.values.max} top=#{top&.join('=')}"
%w[bait airplane negotiate shop mother tree bicycle strategy].each do |name|
  word = data["words"].find { |item| item["word"] == name }
  puts "#{name}: #{word["exampleEn"]}"
end
