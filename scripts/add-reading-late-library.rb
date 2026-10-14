# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Late opening at the city library",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Education",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 61,
  "content" => "A\nThe city library used to close at six. Students who work during the day could not get in, and several of them asked the council for later hours.\n\nB\nThe council tried late opening on Thursdays only, until nine. Staff were paid for one extra hour, and two rooms stayed shut to keep the cost down.\n\nC\nIn the first month the reading room was full, but the computers were often free because the wifi failed twice. The trial therefore looked busy and broken at the same time.\n\nD\nA later count showed that most late visitors were students, not shoppers from the high street. The council did not count how many books they borrowed.\n\nE\nNext year the late opening will run on two evenings, but only if the same staff agree to stay. The council will not hire a new night team.",
  "groups" => [
    {
      "type" => "MATCHING_HEADINGS",
      "instruction" => "The passage has five paragraphs, A-E. Choose the correct heading for paragraphs B-E. Paragraph A is an example and is not tested.",
      "options" => [
        { "key" => "i", "text" => "A limited trial on one evening" },
        { "key" => "ii", "text" => "Mixed results in the first month" },
        { "key" => "iii", "text" => "Who the late visitors were" },
        { "key" => "iv", "text" => "The condition for a second evening" },
        { "key" => "v", "text" => "A sharp rise in books borrowed" },
        { "key" => "vi", "text" => "Why the library will close on Sundays" },
        { "key" => "vii", "text" => "A plan to hire a night team" }
      ],
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Paragraph B",
          "answers" => ["i"],
          "evidence" => "The council tried late opening on Thursdays only, until nine."
        },
        {
          "number" => 2,
          "prompt" => "Paragraph C",
          "answers" => ["ii"],
          "evidence" => "The trial therefore looked busy and broken at the same time."
        },
        {
          "number" => 3,
          "prompt" => "Paragraph D",
          "answers" => ["iii"],
          "evidence" => "most late visitors were students, not shoppers from the high street"
        },
        {
          "number" => 4,
          "prompt" => "Paragraph E",
          "answers" => ["iv"],
          "evidence" => "only if the same staff agree to stay"
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
