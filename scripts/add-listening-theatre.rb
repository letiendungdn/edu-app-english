# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A walk around the town theatre",
  "level" => "B2",
  "ieltsPart" => 2,
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "durationSec" => 65,
  "sortOrder" => 63,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Guide: Welcome to the town theatre. I will label five places on the plan. You are standing at number 1, the entrance, on the south side of the building.\nOn your left, number 2 is the box office. Collect your tickets there before six.\nNumber 3, in the middle, is the cloakroom. Bags stay here during the show.\nOn your right, number 4 is the cafe. It opens one hour before the play.\nStraight ahead, at the north end, number 5 is the stage. Please stay behind the rope.",
  "groups" => [
    {
      "type" => "MAP_LABELLING",
      "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/town-theatre.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["entrance"], "evidence" => "number 1, the entrance" },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["box office"], "evidence" => "number 2 is the box office" },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["cloakroom"], "evidence" => "Number 3, in the middle, is the cloakroom" },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["cafe"], "evidence" => "number 4 is the cafe" },
        { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["stage"], "evidence" => "number 5 is the stage" }
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
