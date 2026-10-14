# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A call about the conference hotel",
  "level" => "C1",
  "ieltsPart" => 1,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 70,
  "sortOrder" => 64,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Caller: Hello, I need to change a booking for the linguistics conference.\nReceptionist: The new rate covers breakfast and the airport shuttle. It does not include dinner, a late checkout, or a desk in the room.\nCaller: Which nights are still free?\nReceptionist: We are full on Thursday night and on Sunday night. Wednesday is the night you already hold. Friday and Saturday still have rooms, so you could arrive a day later and leave before Sunday.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO things does the new rate include?",
          "answers" => ["A", "B"],
          "evidence" => "The new rate covers breakfast and the airport shuttle.",
          "options" => [
            { "key" => "A", "text" => "breakfast" },
            { "key" => "B", "text" => "the airport shuttle" },
            { "key" => "C", "text" => "dinner" },
            { "key" => "D", "text" => "a late checkout" },
            { "key" => "E", "text" => "a desk in the room" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO nights is the hotel full?",
          "answers" => ["B", "E"],
          "evidence" => "We are full on Thursday night and on Sunday night.",
          "options" => [
            { "key" => "A", "text" => "Wednesday" },
            { "key" => "B", "text" => "Thursday" },
            { "key" => "C", "text" => "Friday" },
            { "key" => "D", "text" => "Saturday" },
            { "key" => "E", "text" => "Sunday" }
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
