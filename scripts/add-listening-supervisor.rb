# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Choosing a supervisor",
  "level" => "C1",
  "ieltsPart" => 3,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 75,
  "sortOrder" => 57,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lan: We need a supervisor before Friday. I read the staff notes.\nMinh: Dr Patel writes long comments on every draft, but she only meets students once a month. That would be slow when we are stuck.\nLan: Professor Okonkwo is the opposite. He sees his students every Tuesday, yet his notes are only a few lines. You leave the meeting knowing the next step, and you work out the detail yourself.\nMinh: Dr Silva understands the lab equipment better than anyone. The problem is June. She is at a conference for the whole month, and that is when we run the tests.\nLan: Ms Berger offered to help. She joined the department in September and has never supervised a thesis, so I would not ask her to be the main supervisor.\nMinh: Agreed. We can ask her about the library, and we can decide between Patel and Okonkwo tomorrow.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "What do Lan and Minh say about each person? Choose FOUR answers from the box and write the correct letter, A-D.",
      "options" => [
        { "key" => "A", "text" => "Dr Patel" },
        { "key" => "B", "text" => "Professor Okonkwo" },
        { "key" => "C", "text" => "Dr Silva" },
        { "key" => "D", "text" => "Ms Berger" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "writes long comments and meets students once a month",
          "answers" => ["A"],
          "evidence" => "writes long comments on every draft, but she only meets students once a month"
        },
        {
          "number" => 2,
          "prompt" => "meets students every week and writes only a few lines",
          "answers" => ["B"],
          "evidence" => "He sees his students every Tuesday, yet his notes are only a few lines."
        },
        {
          "number" => 3,
          "prompt" => "will be away in June, when the lab tests run",
          "answers" => ["C"],
          "evidence" => "She is at a conference for the whole month, and that is when we run the tests."
        },
        {
          "number" => 4,
          "prompt" => "has never supervised a thesis",
          "answers" => ["D"],
          "evidence" => "has never supervised a thesis"
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
