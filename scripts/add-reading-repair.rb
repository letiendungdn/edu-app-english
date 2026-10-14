# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The Saturday repair cafe",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Community",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 49,
  "content" => "A short study followed the town repair cafe through eight Saturdays. Volunteers noted every object that arrived.\nTwo kinds of object made up most of the queue. People brought lamps more often than anything else, and coats were a close second. Phones were turned away, because the volunteers will not open a sealed device. Bicycles were also refused: they take too much floor space. Watches came in small numbers and were not among the two main items.\nThe organisers will make two changes next month. They will set out a second table, and they will finish at four instead of two. They will not charge a fee. They will not move the cafe to Sunday, because the hall is already booked. They will also keep the work voluntary, rather than hire a paid engineer.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO items do people bring most often?",
          "answers" => ["A", "B"],
          "evidence" => "People brought lamps more often than anything else, and coats were a close second.",
          "options" => [
            { "key" => "A", "text" => "lamps" },
            { "key" => "B", "text" => "coats" },
            { "key" => "C", "text" => "phones" },
            { "key" => "D", "text" => "bicycles" },
            { "key" => "E", "text" => "watches" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO changes will the repair cafe make next month?",
          "answers" => ["A", "B"],
          "evidence" => "They will set out a second table, and they will finish at four instead of two.",
          "options" => [
            { "key" => "A", "text" => "a second table" },
            { "key" => "B", "text" => "a later finishing time" },
            { "key" => "C", "text" => "a fee for repairs" },
            { "key" => "D", "text" => "a move to Sunday" },
            { "key" => "E", "text" => "a paid engineer" }
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
