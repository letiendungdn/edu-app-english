# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/vocab.json"

def template?(text)
  text.start_with?(
    "She pointed at the ",
    "His answer seemed ",
    "It is possible to ",
    "She answered ",
    "Please remember the words ",
    "The number ",
    "He said, ",
    "It was city "
  )
end

def fragment?(text)
  return true if text.nil? || text.strip.empty?
  value = text.strip
  return false if template?(value)
  last = value[-1]
  value.match?(/\A[A-Z]/) && [".", "!", "?"].include?(last) ? false : true
end

def gloss(meaning)
  text = meaning.to_s.gsub(/\[[^\]]*\]/, " ").gsub(/\([^)]*\)/, " ").gsub(/\s+/, " ").strip
  part = text.split(/[,;\/|]/).map(&:strip).find { |piece| piece.match?(/[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i) }
  return nil if part.nil?
  part = part.gsub(/[^\p{L}\p{M}\s\-]/u, "").gsub(/\s+/, " ").strip
  return nil if part.length < 2 || part.length > 32
  part
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
  shown = vi || word
  vcap = cap(shown)
  case pos
  when "noun"
    if word.downcase.match?(/\A(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|hundred|thousand)\z/)
      return ["The number #{word} is easy to say.", "Số #{shown} thì dễ đọc."]
    end
    if mass?(word)
      frames = [
        ["We learned about #{word} today.", "Hôm nay chúng tôi học về #{shown}."],
        ["She asked about #{word}.", "Cô ấy hỏi về #{shown}."],
        ["#{cap(word)} is part of the lesson.", "#{vcap} là một phần của bài học."]
      ]
    else
      frames = [
        ["I saw #{art} #{word} this morning.", "Sáng nay tôi thấy một #{shown}."],
        ["She bought #{art} #{word} yesterday.", "Hôm qua cô ấy mua một #{shown}."],
        ["We need #{art} #{word} for class.", "Chúng tôi cần một #{shown} cho lớp học."],
        ["The #{word} is new.", "#{vcap} thì mới."]
      ]
    end
    frames[n % frames.size]
  when "adjective"
    frames = [
      ["The result was #{word}.", "Kết quả thì #{shown}."],
      ["It felt #{word}.", "Nó có vẻ #{shown}."],
      ["Her answer was #{word}.", "Câu trả lời của cô ấy thì #{shown}."]
    ]
    frames[n % frames.size]
  when "verb"
    frames = [
      ["They want to #{word}.", "Họ muốn #{shown}."],
      ["She learned how to #{word}.", "Cô ấy học cách #{shown}."],
      ["We decided to #{word}.", "Chúng tôi quyết định #{shown}."]
    ]
    frames[n % frames.size]
  when "adverb"
    frames = [
      ["She spoke #{word}.", "Cô ấy nói #{shown}."],
      ["He replied #{word}.", "Anh ấy trả lời #{shown}."]
    ]
    frames[n % frames.size]
  when "interjection"
    ["He said, \"#{cap(word)}!\"", "Anh ấy nói: \"#{vcap}!\""]
  when "preposition"
    ["It was city #{word} country.", "Đó là thành phố #{shown} nông thôn."]
  else
    ["People say \"#{word}\".", "Người ta nói \"#{shown}\"."]
  end
end

data = JSON.parse(File.read(PATH))
replaced = 0
vi_kept = 0
samples = []
data["words"].each do |item|
  if item["word"].downcase == "bai"
    item["phonetic"] = "/baɪ/"
    item["meaningVi"] = "khoảng trống trong rừng"
    item["exampleVi"] = "Động vật hay đến khoảng trống ngập nước trong rừng vì ở đó có cây giàu muối khoáng."
    next
  end
  en = item["exampleEn"].to_s.strip
  next if en.empty?
  next unless template?(en) || fragment?(en)
  vi = gloss(item["meaningVi"])
  sentence, translation = pair(item["word"], item["partOfSpeech"], vi)
  next if sentence.length > 240 || translation.length > 240
  item["exampleEn"] = sentence
  item["exampleVi"] = vi.nil? ? "" : translation
  vi_kept += 1 unless vi.nil?
  replaced += 1
  samples << "#{item["partOfSpeech"]} #{item["word"]}: #{sentence} | #{item["exampleVi"]}" if samples.size < 12
end

thin = data["words"].count { |item| template?(item["exampleEn"].to_s) || fragment?(item["exampleEn"].to_s) }
blank_vi = data["words"].count { |item| item["exampleVi"].to_s.strip.empty? }
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "replaced=#{replaced} with_vi=#{vi_kept} still_thin=#{thin} blank_vi=#{blank_vi}"
puts samples.join("\n")
