# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Visitors to the night market",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Town planning",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 47,
  "content" => "A city university has published a short study of the Saturday night market. Researchers stopped four hundred visitors as they left and asked why they had come.\nTwo reasons dominated the answers. Most people named the food, and almost as many named the live music at the east end of the square. The clothes stalls drew only a small share of visitors. Parking is not free: drivers pay after six, and few people cited it as a reason to come. The last bus currently leaves at nine, which several visitors called too early, but they did not list the bus itself as a reason they had attended.\nThe council has accepted two changes before the next season. It will add litter bins along the food row, and it will hold the last bus until eleven. It will not build a stage, because the musicians already use the existing steps. It will not cut food prices, which the study treats as a matter for the stalls. It will also leave the clothes stalls where they are.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO reasons did most visitors give for coming?",
          "answers" => ["A", "B"],
          "evidence" => "Most people named the food, and almost as many named the live music",
          "options" => [
            { "key" => "A", "text" => "the food" },
            { "key" => "B", "text" => "the live music" },
            { "key" => "C", "text" => "the clothes stalls" },
            { "key" => "D", "text" => "free parking" },
            { "key" => "E", "text" => "the last bus" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO changes will the council make before next season?",
          "answers" => ["A", "B"],
          "evidence" => "It will add litter bins along the food row, and it will hold the last bus until eleven.",
          "options" => [
            { "key" => "A", "text" => "more litter bins" },
            { "key" => "B", "text" => "a later last bus" },
            { "key" => "C", "text" => "a new stage" },
            { "key" => "D", "text" => "cheaper food" },
            { "key" => "E", "text" => "closing the clothes stalls" }
          ]
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
