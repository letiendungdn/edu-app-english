# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Plans for the class party",
  "level" => "A2",
  "ieltsPart" => 3,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 70,
  "sortOrder" => 80,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Anna: Let's have the class party on Friday.\nBen: Friday is the football match. Saturday is better.\nAnna: Saturday morning?\nBen: No. Saturday afternoon. The morning is the swimming class.\nAnna: Where shall we have it?\nBen: Not in the classroom. The classroom is too small. Let's use the school hall.\nAnna: What food shall we buy?\nBen: Cake. Not pizza. Pizza is too expensive. And juice, not cola.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B or C.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which day is the party?",
          "answers" => ["B"],
          "evidence" => "Saturday is better.",
          "options" => [
            { "key" => "A", "text" => "Friday" },
            { "key" => "B", "text" => "Saturday" },
            { "key" => "C", "text" => "Sunday" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "What time is the party?",
          "answers" => ["C"],
          "evidence" => "Saturday afternoon.",
          "options" => [
            { "key" => "A", "text" => "in the morning" },
            { "key" => "B", "text" => "at noon" },
            { "key" => "C", "text" => "in the afternoon" }
          ]
        },
        {
          "number" => 3,
          "prompt" => "Where will the party be?",
          "answers" => ["A"],
          "evidence" => "Let's use the school hall.",
          "options" => [
            { "key" => "A", "text" => "in the school hall" },
            { "key" => "B", "text" => "in the classroom" },
            { "key" => "C", "text" => "in the park" }
          ]
        },
        {
          "number" => 4,
          "prompt" => "What food will they buy?",
          "answers" => ["B"],
          "evidence" => "Cake. Not pizza.",
          "options" => [
            { "key" => "A", "text" => "pizza" },
            { "key" => "B", "text" => "cake" },
            { "key" => "C", "text" => "sandwiches" }
          ]
        },
        {
          "number" => 5,
          "prompt" => "What will they drink?",
          "answers" => ["A"],
          "evidence" => "And juice, not cola.",
          "options" => [
            { "key" => "A", "text" => "juice" },
            { "key" => "B", "text" => "cola" },
            { "key" => "C", "text" => "tea" }
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
