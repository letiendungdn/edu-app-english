# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Plans for the class picnic",
  "level" => "A2",
  "ieltsPart" => 3,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 65,
  "sortOrder" => 60,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lan: We need food for the class picnic.\nMinh: Let's buy bread and juice. My mum will bring a cake, so we do not need one. Crisps are too salty, and we already have apples at home.\nLan: Where can we sit on Saturday?\nMinh: The park is free in the morning, and the school field is free after lunch. The river cafe wants money. The museum garden is closed, and the sports hall is for a match.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO things will they buy?",
          "answers" => ["A", "B"],
          "evidence" => "Let's buy bread and juice.",
          "options" => [
            { "key" => "A", "text" => "bread" },
            { "key" => "B", "text" => "juice" },
            { "key" => "C", "text" => "a cake" },
            { "key" => "D", "text" => "crisps" },
            { "key" => "E", "text" => "apples" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO places are free on Saturday?",
          "answers" => ["A", "C"],
          "evidence" => "The park is free in the morning, and the school field is free after lunch.",
          "options" => [
            { "key" => "A", "text" => "the park in the morning" },
            { "key" => "B", "text" => "the river cafe" },
            { "key" => "C", "text" => "the school field after lunch" },
            { "key" => "D", "text" => "the museum garden" },
            { "key" => "E", "text" => "the sports hall" }
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
