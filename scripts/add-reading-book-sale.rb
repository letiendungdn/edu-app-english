# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The library book sale",
  "level" => "A2",
  "module" => "GENERAL",
  "topic" => "Community",
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "estimatedMin" => 6,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 54,
  "content" => "The town library will hold a book sale on Saturday. People can bring novels and children's books. The library does not want textbooks, magazines, or dictionaries.\nThe sale opens at ten and closes at two. Helpers are needed at the door and at the cash desk. Nobody is needed in the kitchen, in the car park, or in the children's room, because those places stay closed.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO kinds of books can people bring?",
          "answers" => ["A", "B"],
          "evidence" => "People can bring novels and children's books.",
          "options" => [
            { "key" => "A", "text" => "novels" },
            { "key" => "B", "text" => "children's books" },
            { "key" => "C", "text" => "textbooks" },
            { "key" => "D", "text" => "magazines" },
            { "key" => "E", "text" => "dictionaries" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO places need helpers?",
          "answers" => ["A", "C"],
          "evidence" => "Helpers are needed at the door and at the cash desk.",
          "options" => [
            { "key" => "A", "text" => "the door" },
            { "key" => "B", "text" => "the kitchen" },
            { "key" => "C", "text" => "the cash desk" },
            { "key" => "D", "text" => "the car park" },
            { "key" => "E", "text" => "the children's room" }
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
