# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/vocab.json"

def gloss(meaning)
  text = meaning.to_s.gsub(/\[[^\]]*\]/, " ").gsub(/\([^)]*\)/, " ").gsub(/\s+/, " ").strip
  parts = text.split(/[,;\/|]/).map(&:strip).reject(&:empty?)
  chosen = parts.find { |piece| piece.match?(/[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i) }
  chosen ||= parts.find { |piece| piece.length.between?(2, 24) }
  return nil if chosen.nil?

  chosen = chosen.gsub(/[^\p{L}\p{M}\s\-]/u, "").gsub(/\s+/, " ").strip
  words = chosen.split
  while chosen.length > 32 && words.size > 1
    words.pop
    chosen = words.join(" ")
  end
  return nil if chosen.empty? || chosen.length > 32

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

def cap(text)
  return text if text.nil? || text.empty?

  text[0].upcase + text[1..]
end

def pair(word, pos, vi)
  n = word.each_byte.sum
  art = article(word)
  shown = vi
  vcap = cap(shown)
  case pos
  when "noun"
    if word.downcase.match?(/\A(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|hundred|thousand)\z/)
      return ["Learners say the number #{word} out loud.", "Người học đọc số #{shown} thành tiếng."]
    end
    if mass?(word)
      frames = [
        ["Today's class looks at #{word}.", "Lớp hôm nay xem xét #{shown}."],
        ["She wrote one sentence about #{word}.", "Cô ấy viết một câu về #{shown}."],
        ["The reading mentions #{word}.", "Bài đọc nhắc đến #{shown}."],
        ["#{cap(word)} comes up in this lesson.", "#{vcap} xuất hiện trong bài này."]
      ]
    else
      frames = [
        ["The teacher pointed out #{art} #{word}.", "Giáo viên chỉ ra một #{shown}."],
        ["I looked up #{art} #{word} in the lesson.", "Tôi tra một #{shown} trong bài."],
        ["My notes include #{art} #{word}.", "Ghi chú của tôi có một #{shown}."],
        ["We practised the word #{word} today.", "Hôm nay chúng tôi luyện từ #{shown}."],
        ["There is #{art} #{word} in the story.", "Trong chuyện có một #{shown}."],
        ["Can you use #{word} in a sentence?", "Bạn dùng #{shown} trong một câu được không?"]
      ]
    end
    frames[n % frames.size]
  when "adjective"
    frames = [
      ["The answer sounds #{word}.", "Câu trả lời nghe #{shown}."],
      ["That idea seems #{word}.", "Ý đó có vẻ #{shown}."],
      ["The ending felt #{word}.", "Cái kết có vẻ #{shown}."],
      ["People described the place as #{word}.", "Mọi người mô tả nơi đó là #{shown}."]
    ]
    frames[n % frames.size]
  when "verb"
    frames = [
      ["Learners practise how to #{word}.", "Người học luyện cách #{shown}."],
      ["She tried to #{word} during the exercise.", "Cô ấy thử #{shown} trong bài tập."],
      ["We need to #{word} before the test.", "Chúng tôi cần #{shown} trước bài kiểm tra."],
      ["He asked us to #{word}.", "Anh ấy bảo chúng tôi #{shown}."]
    ]
    frames[n % frames.size]
  when "adverb"
    frames = [
      ["She answered #{word}.", "Cô ấy trả lời #{shown}."],
      ["He explained the point #{word}.", "Anh ấy giải thích ý đó #{shown}."],
      ["They finished the task #{word}.", "Họ làm xong việc #{shown}."]
    ]
    frames[n % frames.size]
  when "interjection"
    ["Someone called out \"#{cap(word)}!\".", "Có người kêu \"#{vcap}!\"."]
  when "preposition"
    ["The path goes #{word} the park.", "Con đường đi #{shown} công viên."]
  when "conjunction"
    ["Stay here #{word} wait for me.", "Ở đây #{shown} đợi tôi."]
  when "pronoun"
    ["In the dialogue, #{word} refers to the speaker.", "Trong hội thoại, #{shown} chỉ người nói."]
  else
    ["The lesson uses the phrase \"#{word}\".", "Bài học dùng cụm \"#{shown}\"."]
  end
end

data = JSON.parse(File.read(PATH))
filled = 0
skipped = 0
samples = []
data["words"].each do |item|
  next unless item["exampleVi"].to_s.strip.empty?
  next if item["exampleEn"].to_s.strip.empty?

  vi = gloss(item["meaningVi"])
  if vi.nil?
    skipped += 1
    warn "skip #{item["word"]}: #{item["meaningVi"]}"
    next
  end
  en, example_vi = pair(item["word"], item["partOfSpeech"], vi)
  if en.length > 255 || example_vi.length > 255
    skipped += 1
    warn "long #{item["word"]}"
    next
  end
  item["exampleEn"] = en
  item["exampleVi"] = example_vi
  filled += 1
  samples << "#{item["word"]}: #{en} | #{example_vi}" if samples.size < 12
end

File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "filled=#{filled} skipped=#{skipped}"
puts samples
