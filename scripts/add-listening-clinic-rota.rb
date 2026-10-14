# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A call about the clinic rota",
  "level" => "B2",
  "ieltsPart" => 1,
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "durationSec" => 70,
  "sortOrder" => 75,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Caller: Hello. I am checking the clinic rota for Thursday.\nReceptionist: Dr Khan sees the morning patients. Ms Ortiz runs the vaccine room from ten. Mr Blake answers the phone after lunch. Dr Sen reads the test results in the lab.\nCaller: Does Dr Sen answer the phone as well?\nReceptionist: No. She stays in the lab. And Mr Blake does not see patients. The evening clinic is closed on Thursday.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "Who does each job? Choose FOUR answers from the box and write the correct letter, A-D.",
      "options" => [
        { "key" => "A", "text" => "Dr Khan" },
        { "key" => "B", "text" => "Ms Ortiz" },
        { "key" => "C", "text" => "Mr Blake" },
        { "key" => "D", "text" => "Dr Sen" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "sees the morning patients",
          "answers" => ["A"],
          "evidence" => "Dr Khan sees the morning patients."
        },
        {
          "number" => 2,
          "prompt" => "runs the vaccine room",
          "answers" => ["B"],
          "evidence" => "Ms Ortiz runs the vaccine room from ten."
        },
        {
          "number" => 3,
          "prompt" => "answers the phone after lunch",
          "answers" => ["C"],
          "evidence" => "Mr Blake answers the phone after lunch."
        },
        {
          "number" => 4,
          "prompt" => "reads the test results",
          "answers" => ["D"],
          "evidence" => "Dr Sen reads the test results in the lab."
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
