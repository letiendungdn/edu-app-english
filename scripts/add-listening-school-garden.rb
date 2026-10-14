# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A talk about the school garden",
  "level" => "A2",
  "ieltsPart" => 4,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 70,
  "sortOrder" => 74,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Teacher: Hello. This is a short talk about the school garden. The garden opened in May. The children grow beans. They do not grow tomatoes. Tomatoes come from the market. Flowers are only in the park.\nThe class works in the garden on Friday afternoon. Monday is sports day, so they do not go then. Saturday is for families.\nThe river is too far. The water comes from a blue tank beside the shed. Do not use the kitchen tap. That tap is for cooking.\nThe children do not eat the beans in class. They sell them at the school fair. They do not give them to the park. The money buys new tools.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B or C.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "When did the garden open?",
          "answers" => ["B"],
          "evidence" => "The garden opened in May.",
          "options" => [
            { "key" => "A", "text" => "in March" },
            { "key" => "B", "text" => "in May" },
            { "key" => "C", "text" => "in September" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "What do the children grow?",
          "answers" => ["A"],
          "evidence" => "The children grow beans.",
          "options" => [
            { "key" => "A", "text" => "beans" },
            { "key" => "B", "text" => "tomatoes" },
            { "key" => "C", "text" => "flowers" }
          ]
        },
        {
          "number" => 3,
          "prompt" => "When does the class work in the garden?",
          "answers" => ["B"],
          "evidence" => "The class works in the garden on Friday afternoon.",
          "options" => [
            { "key" => "A", "text" => "on Monday" },
            { "key" => "B", "text" => "on Friday afternoon" },
            { "key" => "C", "text" => "on Saturday" }
          ]
        },
        {
          "number" => 4,
          "prompt" => "Where does the water come from?",
          "answers" => ["B"],
          "evidence" => "The water comes from a blue tank beside the shed.",
          "options" => [
            { "key" => "A", "text" => "the river" },
            { "key" => "B", "text" => "a blue tank" },
            { "key" => "C", "text" => "the kitchen tap" }
          ]
        },
        {
          "number" => 5,
          "prompt" => "What do the children do with the beans?",
          "answers" => ["C"],
          "evidence" => "They sell them at the school fair.",
          "options" => [
            { "key" => "A", "text" => "eat them in class" },
            { "key" => "B", "text" => "give them to the park" },
            { "key" => "C", "text" => "sell them at the school fair" }
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
