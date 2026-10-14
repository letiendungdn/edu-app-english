# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The night bus trial",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Transport",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 63,
  "content" => "A\nThe night bus trial ran for six weeks in October. Buses left the station every half hour from ten until two. The route followed the river road, not the high street.\n\nB\nShop workers were the people who used it most. They finished at eleven and had been walking home. Students used it less often, because the campus already has a late minibus.\n\nC\nThe council counted passengers by hand at the station door. A ticket machine was fitted, but it was not used for the count. Each bus carried about twelve people on a weekday night.\n\nD\nAfter the trial, the council kept the Friday and Saturday buses only. Weeknight buses stopped because the driver cost more than the fares. The river-road route stayed the same on those two nights.",
  "groups" => [
    {
      "type" => "MATCHING_INFORMATION",
      "instruction" => "Which paragraph contains the following information? Write A, B, C or D.",
      "options" => [
        { "key" => "A", "text" => "Paragraph A" },
        { "key" => "B", "text" => "Paragraph B" },
        { "key" => "C", "text" => "Paragraph C" },
        { "key" => "D", "text" => "Paragraph D" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "how often the trial buses left",
          "answers" => ["A"],
          "evidence" => "Buses left the station every half hour"
        },
        {
          "number" => 2,
          "prompt" => "who used the night bus most",
          "answers" => ["B"],
          "evidence" => "Shop workers were the people who used it most."
        },
        {
          "number" => 3,
          "prompt" => "how the council counted passengers",
          "answers" => ["C"],
          "evidence" => "counted passengers by hand at the station door"
        },
        {
          "number" => 4,
          "prompt" => "which nights kept a bus after the trial",
          "answers" => ["D"],
          "evidence" => "kept the Friday and Saturday buses only"
        }
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
