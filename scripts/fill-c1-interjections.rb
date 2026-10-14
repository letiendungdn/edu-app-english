# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/vocab.json"

GLOSSES = {
  "asap" => "As soon as possible.",
  "whereby" => "By means of which.",
  "albeit" => "Although.",
  "supposing" => "If we suppose that.",
  "haha" => "The written sound of a laugh.",
  "hurrah" => "A shout of joy or approval.",
  "meow" => "The sound a cat makes.",
  "phew" => "A sound of relief.",
  "psst" => "A quiet sound used to get someone's attention.",
  "wah" => "The sound of a crying baby.",
  "yuck" => "A word said when something is disgusting.",
  "cum" => "Combined with another role.",
  "notwithstanding" => "In spite of.",
  "unintentionally" => "Without meaning to.",
  "wholeheartedly" => "With complete sincerity.",
  "abracadabra" => "A word magicians say when they do a trick.",
  "banzai" => "A Japanese shout of courage or celebration.",
  "checkmate" => "The call that ends a game of chess, when the king cannot escape.",
  "chop-chop" => "A blunt way to tell someone to hurry.",
  "eureka" => "A shout made when you suddenly discover something.",
  "knock-knock" => "The words that begin a knocking joke.",
  "lol" => "Laughing out loud, written to show amusement.",
  "nom" => "A sound of eating with pleasure.",
  "oink" => "The sound a pig makes.",
  "tick-tock" => "The sound of a clock."
}.freeze

data = JSON.parse(File.read(PATH))
filled = 0
already = 0
data["words"].each do |row|
  key = row["word"].to_s.downcase
  next unless GLOSSES.key?(key)
  if row["meaningEn"].nil? || row["meaningEn"].to_s.strip.empty?
    row["meaningEn"] = GLOSSES[key]
    filled += 1
  else
    already += 1
  end
end
missing = GLOSSES.keys.reject { |key| data["words"].any? { |row| row["word"].to_s.downcase == key } }
puts "filled=#{filled} already=#{already} missing=#{missing.size}"
warn "MISSING #{missing.join(', ')}" unless missing.empty?
File.write(PATH, JSON.pretty_generate(data) + "\n")
