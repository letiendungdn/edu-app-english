# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The town seed library",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Community",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 51,
  "content" => "The town seed library opened in a corner of the public library in 2019. Members borrow a packet of seed in spring and bring a fresh packet back in autumn.\nThe first year was small. Twenty people joined, and most of them grew tomatoes. Beans were added the next spring because they are easy to save.\nThe library does not sell seed. It only lends it. A member who forgets to return a packet is asked to bring one the following year. There is no fine.\nIn winter the shelves are almost empty, because the seed is out in people's gardens. The volunteers use that quiet season to write labels and to throw away packets that are more than three years old.",
  "groups" => [
    {
      "type" => "MATCHING_SENTENCE_ENDINGS",
      "instruction" => "Complete each sentence with the correct ending, A-F.",
      "options" => [
        { "key" => "A", "text" => "return a fresh packet in autumn." },
        { "key" => "B", "text" => "are easy to save." },
        { "key" => "C", "text" => "is asked to bring one the next year." },
        { "key" => "D", "text" => "write labels and throw away old packets." },
        { "key" => "E", "text" => "pays a fine at the desk." },
        { "key" => "F", "text" => "buys seed from the library." }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Members borrow seed in spring and",
          "answers" => ["A"],
          "evidence" => "borrow a packet of seed in spring and bring a fresh packet back in autumn"
        },
        {
          "number" => 2,
          "prompt" => "Beans were added because they",
          "answers" => ["B"],
          "evidence" => "because they are easy to save"
        },
        {
          "number" => 3,
          "prompt" => "A member who forgets to return a packet",
          "answers" => ["C"],
          "evidence" => "is asked to bring one the following year"
        },
        {
          "number" => 4,
          "prompt" => "In winter the volunteers",
          "answers" => ["D"],
          "evidence" => "to write labels and to throw away packets"
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
