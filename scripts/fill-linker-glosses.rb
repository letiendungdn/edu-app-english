# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/vocab.json"

GLOSSES = {
  "and" => "Used to join words or sentences.",
  "but" => "Used to show a contrast.",
  "or" => "Used to show a choice.",
  "because" => "For the reason that.",
  "if" => "On the condition that.",
  "than" => "Used when comparing two things.",
  "whether" => "Used to talk about a choice or a doubt.",
  "while" => "During the time that.",
  "neither" => "Not one and not the other.",
  "from" => "Starting at a place, a time, or a source.",
  "both" => "The two together.",
  "each" => "Every one in a group, taken separately.",
  "anyone" => "Any person.",
  "anything" => "Any thing.",
  "everyone" => "Every person.",
  "everything" => "All the things.",
  "everybody" => "Every person.",
  "nobody" => "No person.",
  "nothing" => "Not anything.",
  "somebody" => "A person who is not named.",
  "someone" => "A person who is not named.",
  "something" => "A thing that is not named.",
  "myself" => "I, when the speaker does the action to themself.",
  "yourself" => "You, when that person does the action to themself.",
  "theirs" => "Belonging to them.",
  "whose" => "Belonging to which person.",
  "locked" => "Fastened with a lock.",
  "latter" => "The second of two things just mentioned.",
  "jesus" => "The name of Jesus in Christian belief."
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
