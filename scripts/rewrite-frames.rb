# frozen_string_literal: true

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

def frame?(text)
  return false if text.nil? || text.empty?
  return true if text.end_with?(" in the story.", " comes up in this lesson.")
  return true if text.start_with?("We need to ") && text.end_with?(" before the test.")
  return true if text.start_with?("She tried to ") && text.end_with?(" during the exercise.")
  return true if text.start_with?("The path goes ") && text.end_with?(" the park.")
  return true if text.start_with?("Stay here ") && text.end_with?(" wait for me.")
  return true if text.start_with?("In the dialogue, ") && text.end_with?(" the speaker.")
  [
    "The teacher pointed out ",
    "I looked up ",
    "My notes include ",
    "We practised the word ",
    "Can you use ",
    "Today's class looks at ",
    "She wrote one sentence about ",
    "The reading mentions ",
    "Learners practise how to ",
    "He asked us to ",
    "The answer sounds ",
    "That idea seems ",
    "The ending felt ",
    "People described the place as ",
    "She answered ",
    "He explained the point ",
    "They finished the task ",
    "Someone called out ",
    "The lesson uses the phrase ",
    "Learners say the number "
  ].any? { |prefix| text.start_with?(prefix) }
end

KIN = %w[mother father sister brother parent aunt grandmother grandfather grandma grandpa son daughter husband wife friend].freeze

def pair(word, pos, vi)
  n = word.each_byte.sum + word.length
  art = article(word)
  case pos
  when "noun"
    if KIN.include?(word.downcase)
      frames = [
        ["I called my #{word} after dinner.", "Tôi gọi cho #{vi} sau bữa tối."],
        ["My #{word} lives near the market.", "#{vi.capitalize} của tôi ở gần chợ."],
        ["I had lunch with my #{word} on Sunday.", "Chủ nhật tôi ăn trưa với #{vi}."]
      ]
    elsif mass?(word)
      frames = [
        ["The class spent ten minutes on #{word}.", "Lớp dành mười phút cho #{vi}."],
        ["I heard a short talk about #{word}.", "Tôi nghe một bài nói ngắn về #{vi}."],
        ["Our teacher gave an example of #{word}.", "Giáo viên đưa một ví dụ về #{vi}."],
        ["People in the group asked about #{word}.", "Người trong nhóm hỏi về #{vi}."]
      ]
    else
      frames = [
        ["After class, I read a page about #{art} #{word}.", "Sau giờ học, tôi đọc một trang về một #{vi}."],
        ["My sister mentioned #{art} #{word} at dinner.", "Lúc ăn tối, chị tôi nhắc đến một #{vi}."],
        ["We passed #{art} #{word} on the way home.", "Trên đường về, chúng tôi đi ngang một #{vi}."],
        ["The photo on the desk shows #{art} #{word}.", "Bức ảnh trên bàn cho thấy một #{vi}."],
        ["He added #{art} #{word} to his drawing.", "Anh ấy thêm một #{vi} vào bức vẽ."],
        ["Children in the story find #{art} #{word}.", "Bọn trẻ trong chuyện tìm thấy một #{vi}."],
        ["She kept #{art} #{word} in a small box.", "Cô ấy giữ một #{vi} trong một hộp nhỏ."],
        ["A visitor asked the name of the #{word}.", "Một vị khách hỏi tên của #{vi}."]
      ]
    end
    frames[n % frames.size]
  when "adjective"
    frames = [
      ["The morning felt #{word} from the window.", "Từ cửa sổ, buổi sáng có vẻ #{vi}."],
      ["Everyone said the result was #{word}.", "Mọi người nói kết quả thì #{vi}."],
      ["Her reply sounded #{word} on the phone.", "Câu trả lời của cô ấy nghe #{vi} trên điện thoại."],
      ["The street looked #{word} after the rain.", "Con đường trông #{vi} sau cơn mưa."]
    ]
    frames[n % frames.size]
  when "verb"
    frames = [
      ["I hope to #{word} before Friday.", "Tôi hy vọng #{vi} trước thứ Sáu."],
      ["She managed to #{word} on the first try.", "Cô ấy #{vi} được ngay lần đầu."],
      ["They still need time to #{word}.", "Họ vẫn cần thời gian để #{vi}."],
      ["He promised to #{word} after lunch.", "Anh ấy hứa sẽ #{vi} sau bữa trưa."]
    ]
    frames[n % frames.size]
  when "adverb"
    frames = [
      ["She explained the rule #{word}.", "Cô ấy giải thích quy tắc #{vi}."],
      ["He closed the door #{word}.", "Anh ấy đóng cửa #{vi}."],
      ["They walked home #{word}.", "Họ đi bộ về nhà #{vi}."]
    ]
    frames[n % frames.size]
  when "interjection"
    ["From the kitchen, someone shouted \"#{word}!\".", "Từ bếp, có người kêu \"#{vi}!\"."]
  when "preposition"
    ["The cat slipped #{word} the chair.", "Con mèo luồn #{vi} cái ghế."]
  when "conjunction"
    ["Wait here #{word} I come back.", "Đợi ở đây #{vi} tôi quay lại."]
  when "pronoun"
    ["In the story, #{word} is the main character.", "Trong chuyện, #{vi} là nhân vật chính."]
  else
    ["The guide used the phrase \"#{word}\".", "Người hướng dẫn dùng cụm \"#{vi}\"."]
  end
end

data = JSON.parse(File.read(PATH))
changed = 0
skipped = 0
samples = []
data["words"].each do |item|
  en = item["exampleEn"].to_s.strip
  next unless frame?(en)

  vi = gloss(item["meaningVi"])
  if vi.nil?
    skipped += 1
    warn "skip #{item["word"]}"
    next
  end
  new_en, new_vi = pair(item["word"], item["partOfSpeech"], vi)
  if new_en.length > 255 || new_vi.length > 255 || frame?(new_en)
    skipped += 1
    warn "bad #{item["word"]}: #{new_en}"
    next
  end
  item["exampleEn"] = new_en
  item["exampleVi"] = new_vi
  changed += 1
  samples << "#{item["word"]}: #{new_en} | #{new_vi}" if samples.size < 8
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
left = data["words"].count { |item| frame?(item["exampleEn"].to_s) }
puts "changed=#{changed} skipped=#{skipped} still_frame=#{left}"
puts samples
%w[airplane negotiate volcano mother shop].each do |name|
  w = data["words"].find { |item| item["word"] == name }
  puts "KEEP #{name}: #{w["exampleEn"]} | #{w["exampleVi"]}"
end
