# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A visit to the city farm",
  "level" => "A2",
  "ieltsPart" => 2,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 65,
  "sortOrder" => 71,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Guide: Welcome to the city farm. Children can feed the goats and the rabbits. Please do not feed the horses. They are too big. The farmer feeds the hens, and the sheep are in the far field.\nTwo things are free. The tractor ride is free on Saturday, and you can take a map at the gate. The cafe is not free. Pony rides cost three pounds, and the shop sells postcards.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO animals can children feed?",
          "answers" => ["A", "B"],
          "evidence" => "Children can feed the goats and the rabbits.",
          "options" => [
            { "key" => "A", "text" => "the goats" },
            { "key" => "B", "text" => "the rabbits" },
            { "key" => "C", "text" => "the horses" },
            { "key" => "D", "text" => "the hens" },
            { "key" => "E", "text" => "the sheep" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO things are free?",
          "answers" => ["A", "C"],
          "evidence" => "The tractor ride is free on Saturday, and you can take a map at the gate.",
          "options" => [
            { "key" => "A", "text" => "the tractor ride on Saturday" },
            { "key" => "B", "text" => "the cafe" },
            { "key" => "C", "text" => "a map at the gate" },
            { "key" => "D", "text" => "pony rides" },
            { "key" => "E", "text" => "postcards in the shop" }
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
