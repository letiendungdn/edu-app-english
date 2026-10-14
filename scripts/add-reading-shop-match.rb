# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Plans for the empty shop",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Town planning",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 53,
  "content" => "The shop at number twelve has been empty since March. Four neighbours spoke at the last council meeting, and each one wanted something different.\nMaya asked for a bakery. She said the street has nowhere to buy bread, and people walk to the main square even for a loaf.\nJon asked for a repair bench. He said small broken machines are thrown away because there is nowhere nearby to mend them. He would staff the bench on Saturday mornings.\nPriya asked for a reading room. She said the library is full on Saturdays, and students end up sitting on the steps. A quiet room with twenty chairs would take that overflow.\nSam asked the council to leave the shop empty for now. He said the roof leaks after heavy rain, and nobody should move in until that is repaired.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "Match each statement with the correct neighbour, A-D.",
      "options" => [
        { "key" => "A", "text" => "Maya" },
        { "key" => "B", "text" => "Jon" },
        { "key" => "C", "text" => "Priya" },
        { "key" => "D", "text" => "Sam" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "The street has nowhere to buy bread.",
          "answers" => ["A"],
          "evidence" => "the street has nowhere to buy bread"
        },
        {
          "number" => 2,
          "prompt" => "Small broken machines need a place nearby where they can be mended.",
          "answers" => ["B"],
          "evidence" => "there is nowhere nearby to mend them"
        },
        {
          "number" => 3,
          "prompt" => "Saturday readers need more seats than the library can offer.",
          "answers" => ["C"],
          "evidence" => "the library is full on Saturdays"
        },
        {
          "number" => 4,
          "prompt" => "The roof should be repaired before anyone uses the shop.",
          "answers" => ["D"],
          "evidence" => "nobody should move in until that is repaired"
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
