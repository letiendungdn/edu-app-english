# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The school book fair",
  "level" => "A2",
  "module" => "GENERAL",
  "topic" => "School",
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "estimatedMin" => 6,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 60,
  "content" => "The school book fair is on Friday in the hall. It opens at ten and closes at three. Parents can come after one. Students visit with their class in the morning.\nBooks cost from two pounds. Stories and comics are on the front table. Dictionaries stay on the shelf by the door. The school does not sell food at the fair. Juice is in the canteen.\nHelpers wear a red badge. New helpers meet Miss Khan at half past nine so she can show them the tables.",
  "groups" => [
    {
      "type" => "MATCHING_SENTENCE_ENDINGS",
      "instruction" => "Complete each sentence with the correct ending, A-F.",
      "options" => [
        { "key" => "A", "text" => "at ten on Friday." },
        { "key" => "B", "text" => "after one." },
        { "key" => "C", "text" => "on the shelf by the door." },
        { "key" => "D", "text" => "at half past nine." },
        { "key" => "E", "text" => "on Saturday morning." },
        { "key" => "F", "text" => "in the canteen." }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "The book fair opens",
          "answers" => ["A"],
          "evidence" => "It opens at ten"
        },
        {
          "number" => 2,
          "prompt" => "Parents can come",
          "answers" => ["B"],
          "evidence" => "Parents can come after one."
        },
        {
          "number" => 3,
          "prompt" => "Dictionaries stay",
          "answers" => ["C"],
          "evidence" => "Dictionaries stay on the shelf by the door."
        },
        {
          "number" => 4,
          "prompt" => "New helpers meet Miss Khan",
          "answers" => ["D"],
          "evidence" => "New helpers meet Miss Khan at half past nine"
        }
      ]
    }
  ]
}.freeze

data = JSON.parse(File.read(PATH))
titles = data["passages"].map { |item| item["title"] }
if titles.include?(PASSAGE["title"])
  warn "skip #{PASSAGE["title"]}"
else
  data["passages"] << PASSAGE
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "passages=#{data["passages"].size}"
