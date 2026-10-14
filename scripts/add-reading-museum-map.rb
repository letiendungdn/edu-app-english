# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The science museum floor",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Museums",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 48,
  "content" => "The ground floor of the science museum is shown on the plan. Point 1, at the south edge, is the entrance. Tickets are checked there, and bags larger than a laptop must be left in the lockers beside the door.\nPoint 2, on the west side, is the planetarium. Shows begin every hour, and late arrivals wait for the next one. Point 3, in the middle of the floor, is the shop. It sells posters and small kits, and it stays open for half an hour after the galleries close.\nPoint 4, on the east side, is the cafe. Hot food is served until three, and after that only drinks and cake are available. Point 5, at the north end, is the lecture room. The afternoon talk is free, but visitors need a ticket from the entrance.",
  "groups" => [
    {
      "type" => "MAP_LABELLING",
      "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/science-museum.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["entrance"], "evidence" => "Point 1, at the south edge, is the entrance." },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["planetarium"], "evidence" => "Point 2, on the west side, is the planetarium." },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["shop"], "evidence" => "Point 3, in the middle of the floor, is the shop." },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["cafe"], "evidence" => "Point 4, on the east side, is the cafe." },
        { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["lecture room"], "evidence" => "Point 5, at the north end, is the lecture room." }
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
