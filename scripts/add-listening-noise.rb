# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Four studies of city noise",
  "level" => "C1",
  "ieltsPart" => 4,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 75,
  "sortOrder" => 61,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lecturer: Four studies help the council decide where to put a night bus.\nDr Ahmed recorded sleep in fifty flats. She found that traffic noise after midnight cuts deep sleep, even when people say they are used to it.\nProfessor Lind did not stand on the street. He measured noise inside bedrooms, with the windows closed, and that figure was lower than the street reading.\nDr Costa looked at trees. A row of trees along a road lowers the noise by a small amount, but it does not remove it.\nMs Okada checked the method. She warned that one week of data is too short to judge a whole year, because summer nights are quieter than winter nights.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "What does each person say about city noise? Choose FOUR answers from the box and write the correct letter, A-D.",
      "options" => [
        { "key" => "A", "text" => "Dr Ahmed" },
        { "key" => "B", "text" => "Professor Lind" },
        { "key" => "C", "text" => "Dr Costa" },
        { "key" => "D", "text" => "Ms Okada" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "traffic noise after midnight cuts deep sleep",
          "answers" => ["A"],
          "evidence" => "traffic noise after midnight cuts deep sleep"
        },
        {
          "number" => 2,
          "prompt" => "measured noise inside bedrooms, not on the street",
          "answers" => ["B"],
          "evidence" => "He measured noise inside bedrooms, with the windows closed"
        },
        {
          "number" => 3,
          "prompt" => "trees along a road lower the noise only a little",
          "answers" => ["C"],
          "evidence" => "A row of trees along a road lowers the noise by a small amount"
        },
        {
          "number" => 4,
          "prompt" => "one week of data is too short to judge a whole year",
          "answers" => ["D"],
          "evidence" => "one week of data is too short to judge a whole year"
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
