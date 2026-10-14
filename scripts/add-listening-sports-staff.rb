# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Who is working at the sports centre",
  "level" => "A2",
  "ieltsPart" => 1,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 60,
  "sortOrder" => 69,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Caller: Hello, is that the sports centre?\nReceptionist: Yes. How can I help?\nCaller: Who is working today?\nReceptionist: Sam opens the pool at seven. Nina teaches the swimming class at nine. Omar sells tickets at the desk. Lily locks the doors at eight. Pat cleans the cafe, but that is a different job. Jo is off today.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "Who does each job? Choose FOUR answers from the box and write the correct letter, A-D.",
      "options" => [
        { "key" => "A", "text" => "Sam" },
        { "key" => "B", "text" => "Nina" },
        { "key" => "C", "text" => "Omar" },
        { "key" => "D", "text" => "Lily" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "opens the pool",
          "answers" => ["A"],
          "evidence" => "Sam opens the pool at seven."
        },
        {
          "number" => 2,
          "prompt" => "teaches the swimming class",
          "answers" => ["B"],
          "evidence" => "Nina teaches the swimming class at nine."
        },
        {
          "number" => 3,
          "prompt" => "sells tickets at the desk",
          "answers" => ["C"],
          "evidence" => "Omar sells tickets at the desk."
        },
        {
          "number" => 4,
          "prompt" => "locks the doors",
          "answers" => ["D"],
          "evidence" => "Lily locks the doors at eight."
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
