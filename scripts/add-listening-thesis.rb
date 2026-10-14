# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A call about the thesis defence",
  "level" => "C1",
  "ieltsPart" => 1,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 70,
  "sortOrder" => 76,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Caller: Hello. I am calling about my thesis defence.\nReceptionist: It is on Thursday, in the seminar room. Wednesday is the faculty meeting, so that day is closed.\nCaller: Which floor is the room on?\nReceptionist: The third floor. The ground floor is only the waiting room.\nCaller: And the time?\nReceptionist: It starts at two. The ten o'clock slot is the library tour, not your defence.\nCaller: Should I bring a projector?\nReceptionist: No. The slides are already on the room computer. Please bring two printed copies of the thesis. The examiners sit at the front table. You stand at the lectern. Guests sit at the back.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B or C.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which day is the defence?",
          "answers" => ["B"],
          "evidence" => "It is on Thursday, in the seminar room.",
          "options" => [
            { "key" => "A", "text" => "Wednesday" },
            { "key" => "B", "text" => "Thursday" },
            { "key" => "C", "text" => "Friday" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which floor is the seminar room on?",
          "answers" => ["A"],
          "evidence" => "The third floor.",
          "options" => [
            { "key" => "A", "text" => "the third floor" },
            { "key" => "B", "text" => "the ground floor" },
            { "key" => "C", "text" => "the basement" }
          ]
        },
        {
          "number" => 3,
          "prompt" => "What time does the defence start?",
          "answers" => ["C"],
          "evidence" => "It starts at two.",
          "options" => [
            { "key" => "A", "text" => "at ten" },
            { "key" => "B", "text" => "at noon" },
            { "key" => "C", "text" => "at two" }
          ]
        },
        {
          "number" => 4,
          "prompt" => "What should the candidate bring?",
          "answers" => ["B"],
          "evidence" => "Please bring two printed copies of the thesis.",
          "options" => [
            { "key" => "A", "text" => "a projector" },
            { "key" => "B", "text" => "two printed copies" },
            { "key" => "C", "text" => "the slides on a laptop" }
          ]
        },
        {
          "number" => 5,
          "prompt" => "Where do the examiners sit?",
          "answers" => ["A"],
          "evidence" => "The examiners sit at the front table.",
          "options" => [
            { "key" => "A", "text" => "at the front table" },
            { "key" => "B", "text" => "at the lectern" },
            { "key" => "C", "text" => "at the back" }
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
