# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Four views on city trees",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Town planning",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 46,
  "content" => "A recent seminar brought together four researchers who disagree about how cities should plant trees.\nDr Lena Ortiz measured air temperature on two narrow streets that were alike in every way except shade. On the street with a continuous line of trees, the afternoon reading was three degrees lower. She argues that this cooling is the clearest benefit cities can expect, and that wide avenues already have enough breeze to need fewer trees.\nProfessor Hasan Malik looked at repair records rather than temperature. Where roots had been planted within two metres of old clay drains, the pipes cracked within a decade. He does not oppose trees, but he insists that the planting line must stay clear of ageing pipes.\nDr Mei Chen followed forty newly planted trees through their first summer. The ones that survived were not those nearest a tap. They were the ones on blocks where a single neighbour had agreed to water them twice a week and to remind the others. Without that person, even well-sited trees dried out.\nProfessor Owen Blake is less interested in how many species a park contains. He tracked small birds and found that they rarely crossed a busy road unless a line of trees or shrubs joined one green space to the next. A long list of species inside one isolated park, he says, does less for those birds than a plain corridor between parks.",
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "Match each statement with the correct researcher, A-D.",
      "options" => [
        { "key" => "A", "text" => "Dr Lena Ortiz" },
        { "key" => "B", "text" => "Professor Hasan Malik" },
        { "key" => "C", "text" => "Dr Mei Chen" },
        { "key" => "D", "text" => "Professor Owen Blake" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Shade from trees lowers the afternoon temperature on a narrow street.",
          "answers" => ["A"],
          "evidence" => "the afternoon reading was three degrees lower"
        },
        {
          "number" => 2,
          "prompt" => "Roots planted too near old drains can crack the pipes.",
          "answers" => ["B"],
          "evidence" => "the pipes cracked within a decade"
        },
        {
          "number" => 3,
          "prompt" => "Young trees survive when one neighbour organises the watering.",
          "answers" => ["C"],
          "evidence" => "a single neighbour had agreed to water them twice a week"
        },
        {
          "number" => 4,
          "prompt" => "Birds need a planted link between parks more than a long species list.",
          "answers" => ["D"],
          "evidence" => "a plain corridor between parks"
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
