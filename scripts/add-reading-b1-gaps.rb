# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGES = [
  {
    "title" => "Who runs the Saturday club",
    "level" => "B1",
    "module" => "GENERAL",
    "topic" => "Community",
    "bandMin" => 4.0,
    "bandMax" => 5.5,
    "estimatedMin" => 7,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 76,
    "content" => "The Saturday club needs four helpers.\nAnna collects the coats at the door.\nBen makes the tea in the kitchen.\nCara meets new members and shows them the hall.\nDan locks the hall at the end. Eve wanted to play the piano, but a pianist is already booked. Omar is away.",
    "groups" => [
      {
        "type" => "MATCHING_FEATURES",
        "instruction" => "Who does each job? Choose FOUR answers from the box and write the correct letter, A-D.",
        "options" => [
          { "key" => "A", "text" => "Anna" },
          { "key" => "B", "text" => "Ben" },
          { "key" => "C", "text" => "Cara" },
          { "key" => "D", "text" => "Dan" }
        ],
        "questions" => [
          { "number" => 1, "prompt" => "collects the coats", "answers" => ["A"], "evidence" => "Anna collects the coats at the door." },
          { "number" => 2, "prompt" => "makes the tea", "answers" => ["B"], "evidence" => "Ben makes the tea in the kitchen." },
          { "number" => 3, "prompt" => "meets new members", "answers" => ["C"], "evidence" => "Cara meets new members and shows them the hall." },
          { "number" => 4, "prompt" => "locks the hall", "answers" => ["D"], "evidence" => "Dan locks the hall at the end." }
        ]
      }
    ]
  },
  {
    "title" => "Changes at the town library",
    "level" => "B1",
    "module" => "GENERAL",
    "topic" => "Education",
    "bandMin" => 4.0,
    "bandMax" => 5.5,
    "estimatedMin" => 7,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 77,
    "content" => "A\nThe library now opens at nine on weekdays. It used to open at ten.\n\nB\nChildren may borrow ten books. Adults may borrow six.\n\nC\nThe computers are free for one hour. After that you must book again.\n\nD\nA lost card is replaced at the desk. There is no charge on the first visit. A second card costs two pounds.",
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
          { "number" => 1, "prompt" => "the new weekday opening time", "answers" => ["A"], "evidence" => "opens at nine on weekdays" },
          { "number" => 2, "prompt" => "how many books a child may borrow", "answers" => ["B"], "evidence" => "Children may borrow ten books." },
          { "number" => 3, "prompt" => "how long a free computer session lasts", "answers" => ["C"], "evidence" => "free for one hour" },
          { "number" => 4, "prompt" => "where a lost card is replaced", "answers" => ["D"], "evidence" => "replaced at the desk" }
        ]
      }
    ]
  }
].freeze

data = JSON.parse(File.read(PATH))
titles = data["passages"].map { |item| item["title"] }
PASSAGES.each do |item|
  if titles.include?(item["title"])
    warn "skip #{item["title"]}"
  else
    data["passages"] << item
  end
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "passages=#{data["passages"].size}"
