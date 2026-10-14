# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "New rules for the river path",
  "level" => "B2",
  "ieltsPart" => 4,
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "durationSec" => 70,
  "sortOrder" => 66,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lecturer: The council is changing the river path for two reasons. The path floods after heavy rain, and the lights failed twice last winter. The change is not a response to the new cafe, and cyclists did not ask for it. The ferry timetable is also unchanged.\nTwo things will stay the same. The path remains free, and dogs can still use it on a lead. It will not stay open all night. The council will not add a cafe on the path, and it will not charge a fee.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO reasons does the lecturer give for changing the path?",
          "answers" => ["A", "B"],
          "evidence" => "The path floods after heavy rain, and the lights failed twice last winter.",
          "options" => [
            { "key" => "A", "text" => "the path floods after heavy rain" },
            { "key" => "B", "text" => "the lights failed last winter" },
            { "key" => "C", "text" => "a new cafe opened nearby" },
            { "key" => "D", "text" => "cyclists asked for a change" },
            { "key" => "E", "text" => "the ferry timetable changed" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO things will stay the same?",
          "answers" => ["A", "C"],
          "evidence" => "The path remains free, and dogs can still use it on a lead.",
          "options" => [
            { "key" => "A", "text" => "the path stays free" },
            { "key" => "B", "text" => "the path stays open all night" },
            { "key" => "C", "text" => "dogs can still use the path" },
            { "key" => "D", "text" => "a cafe will open on the path" },
            { "key" => "E", "text" => "walkers will pay a fee" }
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
