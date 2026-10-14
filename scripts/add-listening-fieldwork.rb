# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Choosing a fieldwork site",
  "level" => "B2",
  "ieltsPart" => 3,
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "durationSec" => 70,
  "sortOrder" => 70,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lan: We should pick the river site, not the hill.\nMinh: Agreed. The river is close to the bus, and the council already has last year's data. The hill is quieter, but that is not why we are choosing the river. The lab is not on the site, and the tutor did not recommend the hill.\nLan: What do we take?\nMinh: A permit, and waterproof notebooks. We do not need a drone. The tutor brings his own lunch. The old map is out of date, so leave it.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO reasons do they give for choosing the river?",
          "answers" => ["A", "B"],
          "evidence" => "The river is close to the bus, and the council already has last year's data.",
          "options" => [
            { "key" => "A", "text" => "it is close to the bus" },
            { "key" => "B", "text" => "the council has last year's data" },
            { "key" => "C", "text" => "the site is quiet" },
            { "key" => "D", "text" => "the lab is on the site" },
            { "key" => "E", "text" => "the tutor recommended the hill" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO things must they take?",
          "answers" => ["A", "C"],
          "evidence" => "A permit, and waterproof notebooks.",
          "options" => [
            { "key" => "A", "text" => "a permit" },
            { "key" => "B", "text" => "a drone" },
            { "key" => "C", "text" => "waterproof notebooks" },
            { "key" => "D", "text" => "lunch for the tutor" },
            { "key" => "E", "text" => "the old map" }
          ]
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
