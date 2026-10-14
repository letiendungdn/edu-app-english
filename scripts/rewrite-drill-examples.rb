# frozen_string_literal: true

require "digest"
require "json"

PATH = "backend/src/main/resources/content/vocab.json"
DRY = ARGV.include?("dry")

KEEP = [
  "I saw an airplane this morning."
].freeze

PLACES = [
  "beside the window", "near the station", "inside the museum", "behind the counter",
  "across the street", "next to the cafe", "in the workshop", "on the footbridge",
  "at the bookstall", "by the harbour"
].freeze
TIMES = [
  "on Monday", "on Thursday", "last winter", "this April", "before sunset",
  "in March", "at noon", "early in June"
].freeze
PEOPLE = [
  "Hoa", "Khoa", "Mai", "Nam", "An", "Linh", "Duc", "Ha",
  "The baker", "The driver", "The chef", "The clerk", "The painter", "The farmer",
  "The waiter", "The pilot", "A doctor", "My uncle", "My classmate", "The singer",
  "The coach", "The cashier", "The gardener", "The editor", "The mechanic",
  "The sailor", "The tailor", "The dentist", "My nephew", "The postman"
].freeze

PREFIXES = [
  ["", ""],
  ["Today, ", "Hôm nay, "],
  ["Often, ", "Thường thì, "],
  ["Sometimes, ", "Đôi khi, "],
  ["Now, ", "Bây giờ, "],
  ["Here, ", "Ở đây, "],
  ["Also, ", "Đồng thời, "],
  ["Still, ", "Vẫn, "],
  ["Again, ", "Lại, "],
  ["Nearby, ", "Ở gần đó, "]
].freeze

NOUNS = [
  ["The class read about %{w}.", "Lớp đọc về %{v}."],
  ["She wrote a note about %{w}.", "Cô ấy viết một ghi chú về %{v}."],
  ["His talk explains %{w}.", "Bài nói của anh ấy giải thích về %{v}."],
  ["The video is about %{w}.", "Đoạn video nói về %{v}."],
  ["We found a page about %{w}.", "Chúng tôi tìm thấy một trang về %{v}."],
  ["The guide described %{w}.", "Người hướng dẫn mô tả %{v}."],
  ["Students collected facts about %{w}.", "Học sinh thu thập thông tin về %{v}."],
  ["The article introduces %{w}.", "Bài báo giới thiệu %{v}."],
  ["Her poster shows %{w}.", "Tờ áp phích của cô ấy trình bày %{v}."],
  ["The quiz asks about %{w}.", "Bài kiểm tra hỏi về %{v}."],
  ["He prepared a slide about %{w}.", "Anh ấy chuẩn bị một trang chiếu về %{v}."],
  ["The chapter starts with %{w}.", "Chương bắt đầu bằng %{v}."],
  ["A classmate asked about %{w}.", "Một bạn cùng lớp hỏi về %{v}."],
  ["The podcast mentions %{w}.", "Podcast nhắc đến %{v}."],
  ["Our group presented %{w}.", "Nhóm chúng tôi thuyết trình về %{v}."],
  ["The worksheet defines %{w}.", "Phiếu bài tập định nghĩa %{v}."],
  ["She added %{w} to her outline.", "Cô ấy thêm %{v} vào dàn ý."],
  ["The lecturer returned to %{w}.", "Giảng viên quay lại %{v}."]
].freeze

ADJS = [
  ["She called the result %{w}.", "Cô ấy gọi kết quả là %{v}."],
  ["They needed a %{w} answer.", "Họ cần một câu trả lời %{v}."],
  ["The title sounds %{w}.", "Tiêu đề nghe có vẻ %{v}."],
  ["He chose a %{w} example.", "Anh ấy chọn một ví dụ %{v}."],
  ["The review describes it as %{w}.", "Bài nhận xét mô tả nó là %{v}."],
  ["We looked for something %{w}.", "Chúng tôi tìm một thứ %{v}."],
  ["Her first idea was %{w}.", "Ý đầu tiên của cô ấy thì %{v}."],
  ["The group agreed it felt %{w}.", "Cả nhóm thấy nó có vẻ %{v}."],
  ["I would describe the scene as %{w}.", "Tôi sẽ mô tả cảnh đó là %{v}."],
  ["The second draft looks %{w}.", "Bản nháp thứ hai trông %{v}."],
  ["They settled on a %{w} design.", "Họ chọn một thiết kế %{v}."],
  ["The opening line is %{w}.", "Câu mở đầu thì %{v}."]
].freeze

VERBS = [
  ["The video shows how to %{w}.", "Đoạn video chỉ cách %{v}."],
  ["She asked the class to %{w}.", "Cô ấy yêu cầu lớp %{v}."],
  ["They practised how to %{w}.", "Họ luyện cách %{v}."],
  ["He explained when to %{w}.", "Anh ấy giải thích khi nào thì %{v}."],
  ["The worksheet says to %{w}.", "Phiếu bài tập bảo %{v}."],
  ["We listened to people %{w}.", "Chúng tôi nghe mọi người %{v}."],
  ["The teacher modelled how to %{w}.", "Giáo viên làm mẫu cách %{v}."],
  ["Her notes remind her to %{w}.", "Ghi chú nhắc cô ấy %{v}."],
  ["The coach told them to %{w}.", "Huấn luyện viên bảo họ %{v}."],
  ["A friend asked him to %{w}.", "Một người bạn nhờ anh ấy %{v}."],
  ["The instructions tell you to %{w}.", "Hướng dẫn bảo bạn %{v}."],
  ["She wants the team to %{w}.", "Cô ấy muốn đội %{v}."]
].freeze

OTHER = [
  ["The dialogue uses %{w}.", "Đoạn hội thoại dùng %{v}."],
  ["Notice %{w} in line two.", "Chú ý %{v} ở dòng hai."],
  ["She highlighted %{w} in the text.", "Cô ấy đánh dấu %{v} trong bài."],
  ["The example sentence contains %{w}.", "Câu ví dụ có %{v}."],
  ["He repeated %{w} slowly.", "Anh ấy nhắc lại %{v} chậm rãi."],
  ["The teacher pointed to %{w}.", "Giáo viên chỉ vào %{v}."],
  ["Learners circled %{w} on the page.", "Người học khoanh %{v} trên trang."],
  ["The subtitle includes %{w}.", "Phụ đề có %{v}."]
].freeze

GLOSSES = {
  "difficult" => "Hard to do or understand.",
  "excellent" => "Extremely good.",
  "pink" => "A pale red colour.",
  "sunny" => "Bright with sunshine.",
  "again" => "One more time.",
  "also" => "In addition; too.",
  "how" => "In what way.",
  "never" => "At no time.",
  "where" => "In or to what place.",
  "why" => "For what reason.",
  "goodbye" => "A word said when leaving.",
  "hello" => "A word said when meeting someone.",
  "hi" => "An informal word said when meeting someone.",
  "no" => "A word used to refuse or deny.",
  "please" => "A polite word used when asking for something.",
  "thanks" => "A word used to show you are grateful.",
  "welcome" => "A word said to greet someone, or to reply to thanks.",
  "wow" => "A word said when you are surprised or impressed.",
  "yes" => "A word used to agree or accept.",
  "august" => "The eighth month of the year.",
  "clothes" => "Things people wear, such as shirts and trousers.",
  "december" => "The twelfth month of the year.",
  "e-mail" => "A message sent from one computer to another.",
  "english" => "The language of England, used in many countries.",
  "february" => "The second month of the year.",
  "feet" => "The plural of foot.",
  "friday" => "The day of the week after Thursday and before Saturday.",
  "hundred" => "The number 100.",
  "january" => "The first month of the year.",
  "jeans" => "Casual trousers made of denim.",
  "july" => "The seventh month of the year.",
  "june" => "The sixth month of the year.",
  "monday" => "The day of the week after Sunday and before Tuesday.",
  "november" => "The eleventh month of the year.",
  "october" => "The tenth month of the year.",
  "parents" => "A person's mother and father.",
  "phone" => "A device used to talk to someone who is somewhere else.",
  "pyjamas" => "Soft clothes worn in bed.",
  "saturday" => "The day of the week after Friday and before Sunday.",
  "september" => "The ninth month of the year.",
  "socks" => "Clothes worn on the feet, inside shoes.",
  "spy" => "A person who secretly collects information.",
  "sunday" => "The day of the week after Saturday and before Monday.",
  "thursday" => "The day of the week after Wednesday and before Friday.",
  "trousers" => "Clothes that cover the legs.",
  "tuesday" => "The day of the week after Monday and before Wednesday.",
  "visitor" => "A person who visits a person or a place.",
  "wednesday" => "The day of the week after Tuesday and before Thursday.",
  "have to" => "Must do something, because it is necessary.",
  "credit card" => "A plastic card used to pay and pay the bank later.",
  "excuse me" => "A polite phrase used to get attention or to apologise.",
  "hate" => "To dislike someone or something very strongly.",
  "fuck" => "A rude word used to swear or to talk about sex.",
  "cannot" => "Not able to do something.",
  "audio" => "Related to sound or recording.",
  "calm" => "Quiet and not excited or angry.",
  "offline" => "Not connected to the internet.",
  "pleasant" => "Nice and enjoyable.",
  "terrorist" => "Using violence and fear for political aims.",
  "unfair" => "Not fair or not just.",
  "wireless" => "Sending signals without wires.",
  "worst" => "The least good.",
  "youngest" => "The least old in a group.",
  "ago" => "Before now.",
  "almost" => "Very nearly.",
  "downstairs" => "On or to a lower floor.",
  "luckily" => "By good luck.",
  "maybe" => "Perhaps; it is possible.",
  "nowadays" => "At the present time.",
  "once" => "One time.",
  "recently" => "Not long ago.",
  "soon" => "In a short time.",
  "unfortunately" => "By bad luck; it is a pity that.",
  "worldwide" => "In the whole world.",
  "cheers" => "A friendly word said when drinking, or to say thanks.",
  "congratulations" => "A word said when someone has done something good.",
  "hey" => "A word used to get someone's attention.",
  "shh" => "A sound people make to ask for quiet.",
  "yep" => "An informal way to say yes.",
  "app" => "A program on a phone or computer.",
  "barcode" => "A pattern of lines that a machine reads.",
  "blackboard" => "A dark board that teachers write on with chalk.",
  "blouse" => "A shirt worn by women.",
  "bluetooth" => "A way for devices to connect over a short distance without wires.",
  "boots" => "Strong shoes that cover the ankle.",
  "chef" => "A professional cook.",
  "countryside" => "Land outside towns, with fields and villages.",
  "crutches" => "Sticks that help a person walk when a leg is hurt.",
  "curry" => "A dish cooked with spices, often with a sauce.",
  "email" => "A message sent from one computer to another.",
  "fitting room" => "A small room in a shop where you try on clothes.",
  "gloves" => "Clothes worn on the hands.",
  "granddaughter" => "The daughter of your son or daughter.",
  "grandson" => "The son of your son or daughter.",
  "headteacher" => "The teacher in charge of a school.",
  "hoodie" => "A sweatshirt with a hood.",
  "inbox" => "The place where new email messages arrive.",
  "internet" => "The worldwide network that connects computers.",
  "kilogram" => "A unit of weight equal to 1,000 grams.",
  "midnight" => "Twelve o'clock at night.",
  "mosque" => "A building where Muslims pray.",
  "only child" => "A child who has no brothers or sisters.",
  "pajamas" => "Soft clothes worn in bed.",
  "sandals" => "Light open shoes.",
  "smartphone" => "A phone that also works as a small computer.",
  "sneakers" => "Soft sports shoes.",
  "sunlight" => "Light that comes from the sun.",
  "twins" => "Two children born to the same mother at the same time.",
  "usb" => "A common way to connect a device or a memory stick to a computer.",
  "give back" => "To return something to the person who owns it.",
  "grow up" => "To change from a child into an adult.",
  "hand in" => "To give a piece of work to a teacher.",
  "hurry up" => "To go faster.",
  "look forward to" => "To feel pleased about something that is going to happen.",
  "run out of" => "To have no more of something left.",
  "sit down" => "To move from standing into a seat.",
  "take care of" => "To look after someone or something.",
  "throw away" => "To put something in the rubbish.",
  "a little" => "A small amount.",
  "as well" => "Too; also.",
  "at least" => "Not less than; if nothing more.",
  "at the moment" => "Now.",
  "by accident" => "Not on purpose.",
  "no one" => "Not one person.",
  "text message" => "A short written message sent by phone.",
  "tour guide" => "A person who shows visitors around a place.",
  "whisper" => "To speak very quietly.",
  "could" => "Used for the past of can, or to say something is possible.",
  "might" => "Used to say something is possible.",
  "must" => "Used to say something is necessary.",
  "should" => "Used to say something is a good idea.",
  "would" => "Used for polite requests or for imagined situations.",
  "ought" => "Used to say something is the right thing to do."
}.freeze

def one_word_frame?(text)
  return false unless text.is_a?(String)

  text.match?(/\AI saw an? \S+ this morning\.\z/) ||
    text.match?(/\AShe bought an? \S+ yesterday\.\z/) ||
    text.match?(/\AWe need an? \S+ for class\.\z/) ||
    text.match?(/\AWe learned about \S+ today\.\z/) ||
    text.match?(/\AShe asked about \S+\.\z/) ||
    text.match?(/\AThe result was \S+\.\z/) ||
    text.match?(/\AHer answer was \S+\.\z/) ||
    text.match?(/\AThey want to \S+\.\z/) ||
    text.match?(/\AShe learned how to \S+\.\z/) ||
    text.match?(/\AWe decided to \S+\.\z/)
end

def loosen?(text)
  return false unless text.is_a?(String)

  PLACES.each do |place|
    return true if text.include?(" sat #{place} while ") && text.end_with?(" watched.")
    TIMES.each do |time|
      return true if text.include?(" fell #{place} #{time}.")
    end
  end
  PEOPLE.any? { |person| text.start_with?("#{person} dropped ") || text.start_with?("#{person} carried ") }
end

def formula?(text)
  one_word_frame?(text) || loosen?(text)
end

def pick(word, list, salt)
  list[Digest::MD5.hexdigest("#{salt}:#{word.downcase}").to_i(16) % list.size]
end

def bank_for(pos)
  case pos
  when "noun", "phrase" then NOUNS
  when "adjective" then ADJS
  when "verb", "phrasal_verb" then VERBS
  else OTHER
  end
end

def short_vi(text)
  raw = text.to_s.gsub(/\[[^\]]*\]/, " ").gsub(/\([^)]*\)/, " ").gsub(/\s+/, " ").strip
  part = raw.split(/[,;\/|]/).map(&:strip).find { |piece| piece.match?(/\p{L}/) }
  return nil if part.nil?

  part = part.gsub(/[^\p{L}\p{M}\p{N}\s\-]/u, "").gsub(/\s+/, " ").strip
  words = part.split
  words = words.take(4) if words.size > 4
  part = words.join(" ")
  return nil if part.empty? || part.length > 32

  part
end

def lower_first(text)
  return text if text.empty? || text.match?(/\A(?:I|I'm)\b/)

  text.sub(/\A[[:upper:]]/) { |letter| letter.downcase }
end

def clip(text)
  text = text.to_s.gsub(/\s+/, " ").strip
  return text if text.length <= 250

  cut = text[0, 249]
  space = cut.rindex(" ")
  cut = cut[0, space] if space && space > 40
  cut = cut.sub(/[,:;]\z/, "")
  cut.end_with?(".", "!", "?") ? cut : "#{cut}."
end

def fill(pattern, word, vi)
  pattern.gsub("%{w}", word).gsub("%{v}", vi)
end

def rewrite(word, pos, meaning_vi)
  vi = short_vi(meaning_vi) || word
  core_en, core_vi = pick(word, bank_for(pos), "core").dup
  prefix_en, prefix_vi = pick(word, PREFIXES, "pre")
  en = fill(core_en, word, vi)
  vi_sentence = fill(core_vi, word, vi)
  if !prefix_en.empty?
    en = prefix_en + lower_first(en)
    vi_sentence = prefix_vi + lower_first(vi_sentence)
  end
  [clip(en), clip(vi_sentence)]
end

data = JSON.parse(File.read(PATH))
changed = 0
kept = 0
glossed = 0
missing_gloss = []
openings = Hash.new(0)
samples = []

data["words"].each do |row|
  word = row["word"].to_s
  key = word.downcase
  if (row["meaningEn"].nil? || row["meaningEn"].to_s.strip.empty?) && GLOSSES.key?(key)
    row["meaningEn"] = GLOSSES[key]
    glossed += 1
  elsif GLOSSES.key?(key) && (row["meaningEn"].nil? || row["meaningEn"].to_s.strip.empty?)
    missing_gloss << key
  end

  example = row["exampleEn"].to_s
  next unless formula?(example)
  if KEEP.include?(example)
    kept += 1
    next
  end

  en, vi = rewrite(word, row["partOfSpeech"].to_s, row["meaningVi"])
  if formula?(en)
    warn "still formula: #{word} :: #{en}"
    next
  end
  row["exampleEn"] = en
  row["exampleVi"] = vi
  changed += 1
  openings[en.downcase.split.take(3).join(" ")] += 1
  samples << [word, en, vi] if samples.size < 8
end

GLOSSES.each_key do |key|
  found = data["words"].any? { |row| row["word"].to_s.downcase == key }
  missing_gloss << key unless found
end

top = openings.max_by { |_key, count| count }
puts "changed=#{changed} kept=#{kept} glossed=#{glossed} missing_words=#{missing_gloss.uniq.size}"
puts "openings=#{openings.size} max=#{top&.last} top=#{top&.first}"
samples.each { |word, en, vi| puts "#{word} | #{en} | #{vi}" }
warn "MISSING #{missing_gloss.uniq.sort.join(', ')}" unless missing_gloss.empty?

unless DRY
  File.write(PATH, JSON.pretty_generate(data) + "\n")
end
