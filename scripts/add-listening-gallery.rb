# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A walk around the art gallery",
  "level" => "B1",
  "ieltsPart" => 2,
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "durationSec" => 65,
  "sortOrder" => 59,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Guide: Welcome to the art gallery. I will label five places on the plan. You are standing at number 1, the entrance, on the south side of the building.\nOn your left, number 2 is the shop. Cards and prints are sold there.\nNumber 3, in the middle, is the cafe. It closes at four.\nOn your right, number 4 is the studio. Children paint there on Saturday.\nStraight ahead, at the north end, number 5 is the paintings. Please do not touch them.",
  "groups" => [
    {
      "type" => "MAP_LABELLING",
      "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/art-gallery.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["entrance"], "evidence" => "number 1, the entrance" },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["shop"], "evidence" => "number 2 is the shop" },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["cafe"], "evidence" => "Number 3, in the middle, is the cafe" },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["studio"], "evidence" => "number 4 is the studio" },
        { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["paintings"], "evidence" => "number 5 is the paintings" }
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
