# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/vocab.json"

GLOSSES = {
  "after" => "Later than a time or an event.",
  "before" => "Earlier than a time or an event.",
  "behind" => "At the back of something.",
  "between" => "In the space that separates two things.",
  "into" => "Moving to the inside of something.",
  "near" => "Close to.",
  "next to" => "At the side of.",
  "under" => "In a lower place than something.",
  "without" => "Not having something.",
  "although" => "In spite of the fact that.",
  "during" => "Throughout a period of time.",
  "until" => "Up to a particular time.",
  "except" => "Not including.",
  "through" => "From one side of something to the other.",
  "toward" => "In the direction of.",
  "among" => "In the middle of a group.",
  "across" => "From one side to the other.",
  "plus" => "Added to.",
  "including" => "Counting something as part of the whole.",
  "since" => "From a time in the past until now.",
  "boiled" => "Cooked in boiling water.",
  "uh-huh" => "A sound that means yes.",
  "huh" => "A sound of surprise or confusion."
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
