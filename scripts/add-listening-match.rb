# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Five trees on the high street",
  "level" => "B2",
  "ieltsPart" => 4,
  "bandMin" => 5.0,
  "bandMax" => 6.5,
  "durationSec" => 80,
  "sortOrder" => 50,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lecturer: The council plants five kinds of tree on the high street, and each kind has one job.\nThe oak is chosen because its roots hold the river bank. It grows slowly, so the council does not use it for shade.\nThe birch stands along the school path. Its pale bark is easy for children to see after dark.\nThe maple is placed in the square for shade in July. The leaves turn red, but colour is not the reason for planting it.\nThe willow grows beside the pond because it takes up extra water after heavy rain.\nThe pine is used next to the bus station. It stays green in winter and blocks the wind.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "What job does each tree do? Choose FIVE answers from the box and write the correct letter, A-E.",
      "options" => [
        { "key" => "A", "text" => "holds the river bank" },
        { "key" => "B", "text" => "easy to see after dark" },
        { "key" => "C", "text" => "gives shade in July" },
        { "key" => "D", "text" => "takes up water after rain" },
        { "key" => "E", "text" => "blocks the winter wind" }
      ],
      "questions" => [
        { "number" => 1, "prompt" => "Oak", "answers" => ["A"], "evidence" => "its roots hold the river bank" },
        { "number" => 2, "prompt" => "Birch", "answers" => ["B"], "evidence" => "easy for children to see after dark" },
        { "number" => 3, "prompt" => "Maple", "answers" => ["C"], "evidence" => "placed in the square for shade in July" },
        { "number" => 4, "prompt" => "Willow", "answers" => ["D"], "evidence" => "takes up extra water after heavy rain" },
        { "number" => 5, "prompt" => "Pine", "answers" => ["E"], "evidence" => "blocks the wind" }
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
