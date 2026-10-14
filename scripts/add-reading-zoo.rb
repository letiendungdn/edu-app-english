# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "A trip to the city zoo",
  "level" => "A2",
  "module" => "GENERAL",
  "topic" => "Free time",
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "estimatedMin" => 6,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 66,
  "content" => "The city zoo is open on Sunday. Tickets cost four pounds for adults. Children pay two pounds. The zoo closes at five.\nVisitors can see the lions near the gate. The monkeys are next to the cafe. Please do not feed the animals. Food is sold only in the cafe.\nThe bus to the zoo leaves the station at ten. The ride takes twenty minutes. Bring a hat if the day is hot. A coat is useful only when it rains.",
  "groups" => [
    {
      "type" => "SUMMARY_COMPLETION",
      "instruction" => "Complete the summary. Write ONE WORD AND/OR A NUMBER from the passage for each answer.",
      "wordLimit" => 1,
      "questions" => [
        {
          "number" => 1,
          "prompt" => "The zoo is open on {{blank}}.",
          "answers" => ["Sunday"],
          "evidence" => "The city zoo is open on Sunday."
        },
        {
          "number" => 2,
          "prompt" => "An adult ticket costs four {{blank}}.",
          "answers" => ["pounds"],
          "evidence" => "Tickets cost four pounds for adults."
        },
        {
          "number" => 3,
          "prompt" => "The monkeys are next to the {{blank}}.",
          "answers" => ["cafe"],
          "evidence" => "The monkeys are next to the cafe."
        },
        {
          "number" => 4,
          "prompt" => "The bus leaves the station at {{blank}}.",
          "answers" => ["ten", "10"],
          "evidence" => "The bus to the zoo leaves the station at ten."
        },
        {
          "number" => 5,
          "prompt" => "On a hot day, visitors should bring a {{blank}}.",
          "answers" => ["hat"],
          "evidence" => "Bring a hat if the day is hot."
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
