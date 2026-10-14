# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Helpers at the Saturday fair",
  "level" => "A2",
  "module" => "GENERAL",
  "topic" => "Community",
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "estimatedMin" => 6,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 62,
  "content" => "The Saturday fair needs four helpers.\nAnna sells cakes at the food table. She does not take the money.\nBen looks after lost children near the gate.\nCara takes the money at the cash desk.\nDan puts the chairs away at the end. Eva wanted to play music, but the band is already booked. Tom is away.",
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
          "prompt" => "sells the cakes",
          "answers" => ["A"],
          "evidence" => "Anna sells cakes at the food table."
        },
        {
          "number" => 2,
          "prompt" => "looks after lost children",
          "answers" => ["B"],
          "evidence" => "Ben looks after lost children near the gate."
        },
        {
          "number" => 3,
          "prompt" => "takes the money",
          "answers" => ["C"],
          "evidence" => "Cara takes the money at the cash desk."
        },
        {
          "number" => 4,
          "prompt" => "puts the chairs away",
          "answers" => ["D"],
          "evidence" => "Dan puts the chairs away at the end."
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
