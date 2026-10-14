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
  ["The postman", "Người đưa thư"], ["The violinist", "Nghệ sĩ vĩ cầm"], ["The porter", "Người khuân vác"],
  ["The florist", "Người bán hoa"], ["The plumber", "Thợ ống nước"], ["A guest", "Một vị khách"],
  ["The captain", "Thuyền trưởng"], ["The journalist", "Nhà báo"], ["My niece", "Cháu gái tôi"],
  ["The architect", "Kiến trúc sư"], ["The chemist", "Dược sĩ"]
].freeze

PLACES = [
  ["beside the window", "bên cửa sổ"],
  ["near the station", "gần nhà ga"],
  ["along the river", "dọc bờ sông"],
  ["inside the museum", "trong bảo tàng"],
  ["behind the counter", "sau quầy"],
  ["under the old tree", "dưới cây cổ thụ"],
  ["across the street", "bên kia đường"],
  ["next to the cafe", "cạnh quán cà phê"],
  ["by the harbour", "ở bến cảng"],
  ["in the workshop", "trong xưởng"],
  ["outside the theatre", "ngoài rạp"],
  ["down the lane", "cuối con hẻm"],
  ["at the bookstall", "ở sạp sách"],
  ["on the footbridge", "trên cầu đi bộ"]
].freeze

TIMES = [
  ["on Monday", "Thứ Hai"],
  ["on Thursday", "Thứ Năm"],
  ["last winter", "Mùa đông năm ngoái"],
  ["this April", "Tháng Tư này"],
  ["just after dawn", "Vừa sau bình minh"],
  ["late at night", "Khuya"],
  ["during the tour", "Trong chuyến tham quan"],
  ["before sunset", "Trước hoàng hôn"],
  ["in March", "Tháng Ba"],
  ["at noon", "Lúc trưa"],
  ["last autumn", "Mùa thu năm ngoái"],
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

def old_drill?(text)
  return false if text.nil? || text.empty?

  people = ["Lan ", "Minh ", "My aunt ", "The nurse ", "A tourist ", "Our neighbour ", "The librarian ", "My cousin "]
  verbs = ["talked about ", "asked about ", "read about ", "heard about ", "decided to ", "wanted to ", "learned to ", "forgot to ", "replied "]
  people.each do |person|
    next unless text.start_with?(person)

    rest = text.delete_prefix(person)
    return true if verbs.any? { |verb| rest.start_with?(verb) }
    return true if rest.start_with?('used the phrase "')
  end
  return true if text.start_with?("The path runs ", "Stay in the classroom ")
  return true if text.start_with?("In the dialogue, ") && text.include?(" refers to ")
  time_openings = [
    "Early in June, ", "Just after dawn, ", "Late at night, ", "During the tour, ",
    "Before sunset, ", "Last winter, ", "This April, ", "On Monday, ",
    "On Thursday, ", "In March, ", "At noon, ", "Last autumn, "
  ]
  return true if time_openings.any? { |opening| text.start_with?(opening) && text.include?(" chose ") }
  return true if text.include?("'s eye ") || text.include?(" belongs with ")
  people_alt = PEOPLE.map { |person, _| person }.join("|")
  return true if text.match?(/\A(?:#{people_alt}) (?:saved|chose) /)

  times = ["This morning, ", "Yesterday, ", "Last Tuesday, ", "After lunch, ", "On Saturday, ", "Before the meeting, "]
  things = ["the street ", "the room ", "the answer ", "the plan ", "her voice ", "the soup "]
  looks = ["looked ", "seemed ", "sounded "]
  times.each do |time|
    next unless text.start_with?(time)

    rest = text.delete_prefix(time)
    things.each do |thing|
      next unless rest.start_with?(thing)

      tail = rest.delete_prefix(thing)
      return true if looks.any? { |look| tail.start_with?(look) }
    end
    return true if rest.include?(' called out "')
  end
  false
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

NOUN_VERBS = [
  ["saved", "giữ"],
  ["stored", "cất"],
  ["labelled", "dán nhãn"],
  ["sketched", "phác"],
  ["weighed", "cân"],
  ["copied", "chép"]
].freeze

def noun_phrase(word)
  mass?(word) ? word : "#{article(word)} #{word}"
end

def unit(word, vi)
  mass?(word) ? vi : "một #{vi}"
end

def pair(word, pos, vi)
  person, person_vi = pick(word, PEOPLE, "p")
  place, place_vi = pick(word, PLACES, "l")
  time, time_vi = pick(word, TIMES, "t")
  shown = cap(word)
  noun = noun_phrase(word)
  one = unit(word, vi)
  who = mid(person)
  verb, verb_vi = pick(word, NOUN_VERBS, "nv")
  shape = Digest::MD5.hexdigest("s:#{word}").to_i(16) % 4
  case pos
  when "noun"
    case shape
    when 0
      ["#{shown} caught #{who}'s eye #{place} #{time}.",
       "#{time_vi}, #{vi} đập vào mắt #{person_vi} #{place_vi}."]
    when 1
      ["#{person} #{verb} #{noun} #{place} #{time}.",
       "#{time_vi}, #{person_vi} #{verb_vi} #{one} #{place_vi}."]
    when 2
      pick_verb, pick_vi = pick(word, [["chose", "chọn"], ["picked", "chọn"], ["selected", "chọn"], ["ordered", "gọi"]], "cv")
      ["#{person} #{pick_verb} #{noun} #{place} #{time}.",
       "#{time_vi}, #{person_vi} #{pick_vi} #{one} #{place_vi}."]
    else
      ["#{shown} belongs with #{who} #{place}.",
       "#{shown} đi cùng #{person_vi} #{place_vi}."]
    end
  when "adjective"
    ["#{person} stayed #{word} #{place} #{time}.",
     "#{time_vi}, #{person_vi} vẫn #{vi} #{place_vi}."]
  when "verb", "phrasal_verb"
    ["#{person} may #{word} #{place} #{time}.",
     "#{time_vi}, #{person_vi} có thể #{vi} #{place_vi}."]
  when "adverb"
    ["#{person} spoke #{word} #{place} #{time}.",
     "#{time_vi}, #{person_vi} nói #{vi} #{place_vi}."]
  when "interjection"
    ["\"#{shown}!\" #{person} shouted #{place} #{time}.",
     "#{time_vi}, #{person_vi} hét \"#{cap(vi)}!\" #{place_vi}."]
  when "preposition"
    ["Walk #{word} the bridge with #{person} #{time}.",
     "#{time_vi}, đi #{vi} cây cầu cùng #{person_vi}."]
  when "conjunction"
    ["Wait #{word} #{person} calls #{time}.",
     "#{time_vi}, đợi #{vi} #{person_vi} gọi."]
  when "pronoun"
    ["#{shown} sat with #{person} #{place} #{time}.",
     "#{time_vi}, #{vi} ngồi với #{person_vi} #{place_vi}."]
  else
    ["\"#{word}\" was the phrase #{person} chose #{time}.",
     "#{time_vi}, \"#{vi}\" là cụm #{person_vi} chọn."]
  end
end

def blocked?(text)
  return true if text.end_with?(" in the story.", " comes up in this lesson.", " lives near the market.")
  return true if text.include?(" is the main character.")
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
    "Wait here ", "The guide used the phrase ", "I had lunch with my ",
    "We need to ", "She tried to ", "The path goes ", "Stay here ", "In the dialogue, "
  ].any? { |prefix| text.start_with?(prefix) }
end

data = JSON.parse(File.read(PATH))
changed = 0
skipped = 0
openings = Hash.new(0)
data["words"].each do |item|
  en = item["exampleEn"].to_s.strip
  next unless old_drill?(en)

  vi = gloss(item["meaningVi"])
  if vi.nil?
    skipped += 1
    next
  end
  new_en, new_vi = pair(item["word"], item["partOfSpeech"], vi)
  if new_en.length > 255 || new_vi.length > 255 || blocked?(new_en) || new_en[0] !~ /[A-Z"']/
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
left = data["words"].count { |item| old_drill?(item["exampleEn"].to_s) }
top = openings.max_by { |_, count| count }
puts "changed=#{changed} skipped=#{skipped} still=#{left} openings=#{openings.size} max=#{openings.values.max} top=#{top&.join("=")}"
%w[airplane negotiate bone volcano shop mother].each do |name|
  w = data["words"].find { |item| item["word"] == name }
  puts "#{name}: #{w["exampleEn"]} | #{w["exampleVi"]}"
end
