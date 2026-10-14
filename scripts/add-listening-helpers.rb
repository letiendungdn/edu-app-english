# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Helpers for the school trip",
  "level" => "A2",
  "ieltsPart" => 3,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 60,
  "sortOrder" => 65,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lan: We need four helpers for the school trip.\nMinh: Anna brings the water. She already bought two big bottles.\nLan: Ben carries the map. He knows the path to the lake.\nMinh: Cara counts the children when we get on the bus.\nLan: Dan calls the bus company if we are late. Eva wanted to take photos, but we do not need a photographer. Tom will stay at school.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "Who does each job? Choose FOUR answers from the box and write the correct letter, A-D.",
      "options" => [
        { "key" => "A", "text" => "Anna" },
        { "key" => "B", "text" => "Ben" },
        { "key" => "C", "text" => "Cara" },
        { "key" => "D", "text" => "Dan" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "brings the water",
          "answers" => ["A"],
          "evidence" => "Anna brings the water."
        },
        {
          "number" => 2,
          "prompt" => "carries the map",
          "answers" => ["B"],
          "evidence" => "Ben carries the map."
        },
        {
          "number" => 3,
          "prompt" => "counts the children",
          "answers" => ["C"],
          "evidence" => "Cara counts the children when we get on the bus."
        },
        {
          "number" => 4,
          "prompt" => "calls the bus company",
          "answers" => ["D"],
          "evidence" => "Dan calls the bus company if we are late."
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
