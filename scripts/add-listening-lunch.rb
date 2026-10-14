# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Changes to the school lunch",
  "level" => "B1",
  "ieltsPart" => 4,
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "durationSec" => 65,
  "sortOrder" => 68,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lecturer: The school is changing lunch for two reasons. The queue is too long, and too much food is thrown away. The price is not going up. Students did not ask for pizza, and the kitchen is not closing.\nTwo things will stay the same. Lunch is still free, and students can still sit outside. The break will not stay one hour. The school will not open a shop, and it will not charge a fee.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO reasons does the lecturer give for changing lunch?",
          "answers" => ["A", "B"],
          "evidence" => "The queue is too long, and too much food is thrown away.",
          "options" => [
            { "key" => "A", "text" => "the queue is too long" },
            { "key" => "B", "text" => "too much food is thrown away" },
            { "key" => "C", "text" => "the price is going up" },
            { "key" => "D", "text" => "students asked for pizza" },
            { "key" => "E", "text" => "the kitchen is closing" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO things will stay the same?",
          "answers" => ["A", "C"],
          "evidence" => "Lunch is still free, and students can still sit outside.",
          "options" => [
            { "key" => "A", "text" => "lunch stays free" },
            { "key" => "B", "text" => "the break stays one hour" },
            { "key" => "C", "text" => "students can sit outside" },
            { "key" => "D", "text" => "a shop will open" },
            { "key" => "E", "text" => "students will pay a fee" }
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
