# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Reporting a leak in the flat",
  "level" => "B2",
  "ieltsPart" => 1,
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "durationSec" => 70,
  "sortOrder" => 58,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Caller: Hello, is that the housing office?\nOfficer: Yes. How can I help?\nCaller: There is a leak under the kitchen sink, and the light in the hall flickers. I also have a cracked window and a radiator that stays cold.\nOfficer: The engineer can fix the leak and the hall light this week. The window is booked for next month, and the radiator needs a part that has not arrived. The bathroom tap was repaired last Friday, so that one is done.\nCaller: What should I do before the visit?\nOfficer: Please be at home between two and four, and move the pots from under the sink. There is no fee on the day. You already sent a photo, so you do not need another one. Please do not leave a key with a neighbour. Someone must be in the flat.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO problems will the engineer fix this week?",
          "answers" => ["A", "B"],
          "evidence" => "The engineer can fix the leak and the hall light this week.",
          "options" => [
            { "key" => "A", "text" => "the leak under the sink" },
            { "key" => "B", "text" => "the hall light" },
            { "key" => "C", "text" => "the cracked window" },
            { "key" => "D", "text" => "the cold radiator" },
            { "key" => "E", "text" => "the bathroom tap" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO things must the caller do before the visit?",
          "answers" => ["A", "C"],
          "evidence" => "be at home between two and four, and move the pots from under the sink",
          "options" => [
            { "key" => "A", "text" => "be at home between two and four" },
            { "key" => "B", "text" => "pay a fee on the day" },
            { "key" => "C", "text" => "move the pots from under the sink" },
            { "key" => "D", "text" => "send another photo" },
            { "key" => "E", "text" => "leave a key with a neighbour" }
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
