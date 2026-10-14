# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Parts of a pollen trap",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Environment",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 58,
  "content" => "The diagram shows a pollen trap fitted to a hive for a short study. Point 1 is the roof. It keeps rain off the mesh. Bees do not enter through it.\nPoint 2 is the mesh. Returning bees scrape pollen off their legs as they pass. Honey is not collected here.\nPoint 3 is the drawer. Pollen falls into it and is emptied each evening. The drawer is not a feeder.\nPoint 4 is the stand. It lifts the hive above wet ground. It does not hold the pollen.",
  "groups" => [
    {
      "type" => "DIAGRAM_LABEL",
      "instruction" => "Label the diagram. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/pollen-trap.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["roof"], "evidence" => "Point 1 is the roof." },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["mesh"], "evidence" => "Point 2 is the mesh." },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["drawer"], "evidence" => "Point 3 is the drawer." },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["stand"], "evidence" => "Point 4 is the stand." }
      ]
    }
  ]
}.freeze

data = JSON.parse(File.read(PATH))
titles = data["passages"].map { |item| item["title"] }
if titles.include?(PASSAGE["title"])
  warn "skip #{PASSAGE["title"]}"
else
  data["passages"] << PASSAGE
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "passages=#{data["passages"].size}"
