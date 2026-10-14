# frozen_string_literal: true

require "digest"
require "json"

PATH = "backend/src/main/resources/content/vocab.json"

PEOPLE = [
  ["Hoa", "Hoa"], ["Khoa", "Khoa"], ["Mai", "Mai"], ["Nam", "Nam"],
  ["An", "An"], ["Linh", "Linh"], ["Duc", "Đức"], ["Ha", "Hà"],
  ["The baker", "Người làm bánh"], ["The driver", "Tài xế"], ["The chef", "Đầu bếp"],
  ["The clerk", "Nhân viên quầy"], ["The painter", "Hoạ sĩ"], ["The farmer", "Nông dân"],
  ["The waiter", "Bồi bàn"], ["The pilot", "Phi công"], ["A doctor", "Một bác sĩ"],
  ["My uncle", "Chú tôi"], ["My classmate", "Bạn học của tôi"], ["The singer", "Ca sĩ"],
  ["The coach", "Huấn luyện viên"], ["The cashier", "Thu ngân"], ["The gardener", "Người làm vườn"],
  ["The editor", "Biên tập viên"], ["The mechanic", "Thợ máy"], ["The sailor", "Thuỷ thủ"],
  ["The tailor", "Thợ may"], ["The dentist", "Nha sĩ"], ["My nephew", "Cháu trai tôi"],
  ["The postman", "Người đưa thư"]
].freeze

PLACES = [
  ["beside the window", "bên cửa sổ"],
  ["near the station", "gần nhà ga"],
  ["inside the museum", "trong bảo tàng"],
  ["behind the counter", "sau quầy"],
  ["across the street", "bên kia đường"],
  ["next to the cafe", "cạnh quán cà phê"],
  ["in the workshop", "trong xưởng"],
  ["on the footbridge", "trên cầu đi bộ"],
  ["at the bookstall", "ở sạp sách"],
  ["by the harbour", "ở bến cảng"]
].freeze

TIMES = [
  ["on Monday", "Thứ Hai"],
  ["on Thursday", "Thứ Năm"],
  ["last winter", "Mùa đông năm ngoái"],
  ["this April", "Tháng Tư này"],
  ["before sunset", "Trước hoàng hôn"],
  ["in March", "Tháng Ba"],
  ["at noon", "Lúc trưa"],
  ["early in June", "Đầu tháng Sáu"]
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

def frame?(text)
  text.to_s.include?(" belongs with ") || text.to_s.include?("'s eye ")
end

def pick(word, list, shift)
  list[Digest::MD5.hexdigest("#{shift}:#{word}").to_i(16) % list.size]
end

def cap(text)
  text[0].upcase + text[1..]
end

def mid(person)
  return person if person.match?(/\A[A-Z][a-z]+\z/)

  person[0].downcase + person[1..]
end

def noun_phrase(word)
  mass?(word) ? word : "#{article(word)} #{word}"
end

def pair(word, vi)
  person, person_vi = pick(word, PEOPLE, "p2")
  place, place_vi = pick(word, PLACES, "l2")
  time, time_vi = pick(word, TIMES, "t2")
  shown = cap(word)
  noun = noun_phrase(word)
  one = mass?(word) ? vi : "một #{vi}"
  who = mid(person)
  case Digest::MD5.hexdigest("shape2:#{word}").to_i(16) % 4
  when 0
    ["#{shown} fell #{place} #{time}.", "#{time_vi}, #{vi} rơi #{place_vi}."]
  when 1
    ["#{person} dropped #{noun} #{place}.", "#{person_vi} làm rơi #{one} #{place_vi}."]
  when 2
    ["#{shown} sat #{place} while #{who} watched.", "#{vi} nằm #{place_vi} khi #{person_vi} nhìn."]
  else
    ["#{person} carried #{noun} #{place} #{time}.", "#{time_vi}, #{person_vi} mang #{one} #{place_vi}."]
  end
end

data = JSON.parse(File.read(PATH))
changed = 0
skipped = 0
openings = Hash.new(0)
data["words"].each do |item|
  next unless frame?(item["exampleEn"])

  vi = gloss(item["meaningVi"])
  if vi.nil?
    skipped += 1
    next
  end
  new_en, new_vi = pair(item["word"], vi)
  if new_en.length > 255 || new_vi.length > 255 || frame?(new_en)
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
left = data["words"].count { |item| frame?(item["exampleEn"]) }
top = openings.max_by { |_, count| count }
puts "changed=#{changed} skipped=#{skipped} still=#{left} openings=#{openings.size} max=#{openings.values.max} top=#{top&.join("=")}"
%w[bone volcano airplane shop mother].each do |name|
  word = data["words"].find { |item| item["word"] == name }
  puts "#{name}: #{word["exampleEn"]} | #{word["exampleVi"]}"
end
