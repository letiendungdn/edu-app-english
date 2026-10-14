# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "The market noise study",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Environment",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 65,
  "content" => "Researchers measured noise at the Saturday market for four weeks. The music stall was the loudest. People expected the food stall to be louder, but it was not. The book stall was the quietest. The toy stall was only a little quieter than the music stall.\nMeasurements started at nine and stopped at one. They did not continue until three. Volunteers used a meter. Phones were not allowed.\nThe average level was 78 decibels. One Saturday reached 90, but that figure was left out of the average. A short note appeared in March. The full report will be published in June.",
  "groups" => [
    {
      "type" => "SHORT_ANSWER",
      "instruction" => "Answer the questions. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
      "wordLimit" => 2,
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which stall was the loudest?",
          "answers" => ["music stall", "the music stall", "music"],
          "evidence" => "The music stall was the loudest."
        },
        {
          "number" => 2,
          "prompt" => "Which stall was the quietest?",
          "answers" => ["book stall", "the book stall", "book"],
          "evidence" => "The book stall was the quietest."
        },
        {
          "number" => 3,
          "prompt" => "What time did the measurements stop?",
          "answers" => ["one", "1", "at one"],
          "evidence" => "stopped at one"
        },
        {
          "number" => 4,
          "prompt" => "Which figure was left out of the average?",
          "answers" => ["90"],
          "evidence" => "One Saturday reached 90, but that figure was left out of the average."
        },
        {
          "number" => 5,
          "prompt" => "When will the full report be published?",
          "answers" => ["June", "in June"],
          "evidence" => "The full report will be published in June."
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
