# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/vocab.json"

GLOSSES = {
  "i" => "The person who is speaking.",
  "me" => "The speaker, when they receive the action.",
  "my" => "Belonging to the speaker.",
  "mine" => "Belonging to the speaker, used on its own.",
  "you" => "The person being spoken to.",
  "your" => "Belonging to the person being spoken to.",
  "our" => "Belonging to the speaker and other people.",
  "ours" => "Belonging to the speaker and other people, used on its own.",
  "us" => "The speaker and other people, when they receive the action.",
  "them" => "Those people or things, when they receive the action.",
  "their" => "Belonging to them.",
  "its" => "Belonging to a thing already mentioned.",
  "this" => "The one that is here.",
  "these" => "The ones that are here.",
  "those" => "The ones that are over there.",
  "oneself" => "A person, when they do the action to themself.",
  "thou" => "An old word for you.",
  "any" => "It does not matter which one.",
  "some" => "An amount or a number, not all and not named exactly.",
  "return" => "For a journey to a place and back again."
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
