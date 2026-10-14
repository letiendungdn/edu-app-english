# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The university archive floor",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Education",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 56,
  "content" => "The plan shows the ground floor of the university archive. Point 1, at the south edge, is the entrance. Readers show a card there. The cloakroom beside the door is not marked on the plan.\nPoint 2, on the west side, is the catalogue. Researchers still use it for items acquired before 1980. The computers near the door search only the later records.\nPoint 3, in the middle of the floor, is the reading room. Silence is required, and bags stay in the lockers.\nPoint 4, on the east side, is the store. Only staff may enter. Visitors request a box at the desk and wait.\nPoint 5, at the north end, is the seminar room. The afternoon class is for enrolled students, not for day visitors.",
  "groups" => [
    {
      "type" => "MAP_LABELLING",
      "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/university-archive.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["entrance"], "evidence" => "Point 1, at the south edge, is the entrance." },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["catalogue", "catalog"], "evidence" => "Point 2, on the west side, is the catalogue." },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["reading room"], "evidence" => "Point 3, in the middle of the floor, is the reading room." },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["store"], "evidence" => "Point 4, on the east side, is the store." },
        { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["seminar room"], "evidence" => "Point 5, at the north end, is the seminar room." }
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
