# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Three sites in the winter bird count",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Nature",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 64,
  "content" => "The winter bird count compared three coastal sites. Counters visited each site in a different month and wrote down only the bird that dominated the notes.\nThe harbour wall was counted in January. Ducks were the bird in the notes, and the total was 42. Counters used binoculars. They did not take a hide to the wall.\nThe salt marsh was counted in February. Herons were the bird in the notes, and the total was 18. Counters sat in a hide and left the binoculars behind.\nThe pier was counted in March. Gulls were the bird in the notes, and the total was 7. Counters walked the length of the pier. March was too windy for the hide, and the binoculars stayed in the office.",
  "groups" => [
    {
      "type" => "TABLE_COMPLETION",
      "instruction" => "Complete the table. Write ONE WORD AND/OR A NUMBER.",
      "wordLimit" => 1,
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Harbour wall — month: {{blank}}",
          "answers" => ["January"],
          "evidence" => "The harbour wall was counted in January."
        },
        {
          "number" => 2,
          "prompt" => "Harbour wall — equipment: {{blank}}",
          "answers" => ["binoculars"],
          "evidence" => "Counters used binoculars."
        },
        {
          "number" => 3,
          "prompt" => "Salt marsh — bird: {{blank}}",
          "answers" => ["herons", "heron"],
          "evidence" => "Herons were the bird in the notes"
        },
        {
          "number" => 4,
          "prompt" => "Salt marsh — number: {{blank}}",
          "answers" => ["18"],
          "evidence" => "the total was 18"
        },
        {
          "number" => 5,
          "prompt" => "Pier — month: {{blank}}",
          "answers" => ["March"],
          "evidence" => "The pier was counted in March."
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
