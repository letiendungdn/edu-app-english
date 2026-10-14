# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A walk around the market square",
  "level" => "A2",
  "ieltsPart" => 2,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 55,
  "sortOrder" => 48,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Guide: Welcome to the Saturday market. I will label five places on the plan. You are standing at number 1, the entrance, at the south edge of the square.\nOn your left, number 2 is the bakery. The smell of bread comes from there.\nNumber 3, in the middle, is the fountain. Please do not climb on it.\nOn your right, number 4 is the bookshop. It stays open until six.\nStraight ahead, at the north edge, number 5 is the bus stop. The bus to the station leaves every twenty minutes.",
  "groups" => [
    {
      "type" => "MAP_LABELLING",
      "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/market-square.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["entrance"], "evidence" => "number 1, the entrance" },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["bakery"], "evidence" => "number 2 is the bakery" },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["fountain"], "evidence" => "Number 3, in the middle, is the fountain" },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["bookshop"], "evidence" => "number 4 is the bookshop" },
        { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["bus stop"], "evidence" => "number 5 is the bus stop" }
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
