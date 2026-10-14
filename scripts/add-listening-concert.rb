# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Who does what for the concert",
  "level" => "B1",
  "ieltsPart" => 3,
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "durationSec" => 60,
  "sortOrder" => 72,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lan: We need four people for the concert.\nMinh: Mai prints the tickets. She has the list of names.\nLan: Leo checks the sound before seven. He knows the speakers.\nMinh: Noor welcomes the parents at the door.\nLan: Chris locks the hall at the end. Pia wanted to sell drinks, but the cafe does that. Sam is away this week.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "Who does each job? Choose FOUR answers from the box and write the correct letter, A-D.",
      "options" => [
        { "key" => "A", "text" => "Mai" },
        { "key" => "B", "text" => "Leo" },
        { "key" => "C", "text" => "Noor" },
        { "key" => "D", "text" => "Chris" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "prints the tickets",
          "answers" => ["A"],
          "evidence" => "Mai prints the tickets."
        },
        {
          "number" => 2,
          "prompt" => "checks the sound",
          "answers" => ["B"],
          "evidence" => "Leo checks the sound before seven."
        },
        {
          "number" => 3,
          "prompt" => "welcomes the parents",
          "answers" => ["C"],
          "evidence" => "Noor welcomes the parents at the door."
        },
        {
          "number" => 4,
          "prompt" => "locks the hall",
          "answers" => ["D"],
          "evidence" => "Chris locks the hall at the end."
        }
      ]
    }
  ]
}.freeze

data = JSON.parse(File.read(PATH))
titles = data["tracks"].map { |item| item["title"] }
if titles.include?(TRACK["title"])
  warn "skip #{TRACK["title"]}"
else
  data["tracks"] << TRACK
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "tracks=#{data["tracks"].size}"
