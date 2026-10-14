# frozen_string_literal: true

require "json"
require "open3"

ROOT = "backend/src/main/resources"
MEDIA = File.join(ROOT, "media")
OUT = File.join(ROOT, "content/pictures.json")
EMOJI = JSON.parse(File.read("/tmp/openmoji.json")).reject { |item| item["skintone"].to_s != "" }
BY_NAME = {}
BY_HEX = {}
EMOJI.each do |item|
  BY_NAME[item["annotation"].downcase] ||= item
  BY_HEX[item["hexcode"]] = item
end

SKIP_GROUPS = %w[extras-openmoji extras-unicode component flags symbols].freeze
SKIP_WORDS = %w[bug seal alien lime kite link].freeze

# Mã đã đối chiếu với tên OpenMoji và nghĩa tiếng Việt đang lưu.
ALIAS = {
  "apple" => "1F34E",
  "book" => "1F4D6",
  "water" => "1F6B0",
  "rain" => "1F327",
  "money" => "1F4B0",
  "rice" => "1F35A",
  "milk" => "1F95B",
  "coffee" => "2615",
  "tea" => "1F375",
  "tree" => "1F333",
  "phone" => "1F4F1",
  "computer" => "1F5A5",
  "doctor" => "1F9D1-200D-2695-FE0F",
  "nurse" => "1F469-200D-2695-FE0F",
  "heart" => "2764",
  "hand" => "270B",
  "hat" => "1F9E2",
  "bag" => "1F392",
  "clock" => "23F0",
  "cake" => "1F382",
  "cheese" => "1F9C0",
  "car" => "1F697",
  "moon" => "1F319",
  "snow" => "2744",
  "beach" => "1F3D6",
  "flower" => "1F338",
  "ball" => "26BD",
  "football" => "26BD",
  "soccer" => "26BD",
  "bike" => "1F6B2",
  "plane" => "2708",
  "shoes" => "1F45E",
  "shoe" => "1F45E",
  "gift" => "1F381",
  "truck" => "1F69A",
  "elephant" => "1F418",
  "monkey" => "1F412",
  "strawberry" => "1F353",
  "grapes" => "1F347",
  "orange" => "1F34A",
  "map" => "1F5FA",
  "city" => "1F3D9",
  "lamp" => "1F4A1",
  "knife" => "1F52A",
  "fork" => "1F374",
  "bowl" => "1F963",
  "cup" => "1F375",
  "plate" => "1F37D",
  "leaf" => "1F342",
  "shop" => "1F3EA",
  "breakfast" => "1F95E",
  "vegetable" => "1F966",
  "grandmother" => "1F475",
  "grandma" => "1F475",
  "grandfather" => "1F474",
  "grandpa" => "1F474",
  "arm" => "1F4AA",
  "finger" => "261D",
  "feet" => "1F9B6"
}.freeze

def usable(item)
  item && !SKIP_GROUPS.include?(item["group"])
end

words = JSON.parse(File.read(File.join(ROOT, "content/vocab.json")))["words"]
chosen = {}
words.each do |item|
  word = item["word"].downcase
  next if SKIP_WORDS.include?(word)
  next unless %w[noun phrase adjective].include?(item["partOfSpeech"])

  hex = ALIAS[word]
  emoji = hex ? BY_HEX[hex] : BY_NAME[word]
  if hex
    next unless emoji
  else
    next unless usable(emoji)
    next unless %w[noun phrase].include?(item["partOfSpeech"])
  end

  file = "omoji-#{emoji["hexcode"].downcase}.svg"
  chosen[word] = file
end

Dir.mkdir(MEDIA) unless Dir.exist?(MEDIA)
missing = chosen.values.uniq.reject { |file| File.size?(File.join(MEDIA, file)).to_i > 200 }
puts "words=#{chosen.size} files=#{chosen.values.uniq.size} download=#{missing.size}"

missing.each_slice(12) do |batch|
  threads = batch.map do |file|
    Thread.new do
      hex = file.sub(/\Aomoji-/, "").sub(/\.svg\z/, "").upcase
      url = "https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/color/svg/#{hex}.svg"
      dest = File.join(MEDIA, file)
      _out, status = Open3.capture2("curl", "-fsSL", "-o", dest, url)
      body = File.exist?(dest) ? File.read(dest) : ""
      if status.success? && body.include?("<svg")
        print "."
      else
        File.delete(dest) if File.exist?(dest)
        warn "\nfail #{hex}"
        chosen.delete_if { |_word, name| name == file }
      end
    end
  end
  threads.each(&:join)
end
puts

File.write(OUT, JSON.pretty_generate(chosen.sort.to_h) + "\n")
puts "wrote #{OUT}"
