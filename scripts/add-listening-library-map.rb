# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A walk through the town library",
  "level" => "A2",
  "ieltsPart" => 2,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 60,
  "sortOrder" => 54,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Guide: Welcome to the town library. I will label five places on the plan. You are standing at number 1, the entrance, at the south side of the building.\nOn your left, number 2 is the children's room. Story time is at three.\nNumber 3, in the middle, is the desk. Ask here if you need a card.\nOn your right, number 4 is the quiet room. Please do not talk in there.\nStraight ahead, at the north end, number 5 is the computers. You may use them for one hour.",
  "groups" => [
    {
      "type" => "MAP_LABELLING",
      "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/town-library.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["entrance"], "evidence" => "number 1, the entrance" },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["children's room", "childrens room"], "evidence" => "number 2 is the children's room" },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["desk"], "evidence" => "Number 3, in the middle, is the desk" },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["quiet room"], "evidence" => "number 4 is the quiet room" },
        { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["computers"], "evidence" => "number 5 is the computers" }
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
