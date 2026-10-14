# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The town pool on Saturday",
  "level" => "A2",
  "module" => "GENERAL",
  "topic" => "Daily life",
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "estimatedMin" => 6,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 57,
  "content" => "The Saturday swimming club meets at the town pool. The first class starts at nine. Children under ten must come with a parent. Bring a towel and a swim hat. Goggles are optional.\nThe class costs five pounds, and you pay at the desk. After the class, the cafe sells juice until noon. The shop next to the pool is closed on Saturday.",
  "groups" => [
    {
      "type" => "SENTENCE_COMPLETION",
      "instruction" => "Complete the sentences. Write ONE WORD ONLY from the passage for each answer.",
      "wordLimit" => 1,
      "questions" => [
        {
          "number" => 1,
          "prompt" => "The first class starts at {{blank}}.",
          "answers" => ["nine"],
          "evidence" => "The first class starts at nine."
        },
        {
          "number" => 2,
          "prompt" => "Children under ten must come with a {{blank}}.",
          "answers" => ["parent"],
          "evidence" => "Children under ten must come with a parent."
        },
        {
          "number" => 3,
          "prompt" => "You pay five pounds at the {{blank}}.",
          "answers" => ["desk"],
          "evidence" => "you pay at the desk"
        },
        {
          "number" => 4,
          "prompt" => "The cafe sells juice until {{blank}}.",
          "answers" => ["noon"],
          "evidence" => "the cafe sells juice until noon"
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
