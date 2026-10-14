# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Lights in the town park",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Town planning",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 59,
  "content" => "The town park is lit until midnight, and that habit should change. Paths that stay bright all evening keep people walking home, but the last two hours serve almost nobody. The lights should stay on until ten, and then go off.\nA full switch-off at dusk would be the wrong remedy. In winter the park is already dark by five, and people still cross it after work. They need the paths lit for those hours.\nSome councillors want brighter bulbs. Brightness is not the problem. A stronger lamp at midnight still wastes power and still shines into the houses on Park Road.\nWhether the newer bulbs use less electricity than the old ones is a question for the engineer. It does not change the hour at which the lights should go off.",
  "groups" => [
    {
      "type" => "YES_NO_NOT_GIVEN",
      "instruction" => "Do the following statements agree with the claims of the writer? Write YES, NO or NOT GIVEN.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "The park lights should stay on until ten.",
          "answers" => ["YES"],
          "evidence" => "The lights should stay on until ten, and then go off."
        },
        {
          "number" => 2,
          "prompt" => "The park should be completely dark from dusk.",
          "answers" => ["NO"],
          "evidence" => "A full switch-off at dusk would be the wrong remedy."
        },
        {
          "number" => 3,
          "prompt" => "Brighter bulbs would solve the problem.",
          "answers" => ["NO"],
          "evidence" => "Brightness is not the problem."
        },
        {
          "number" => 4,
          "prompt" => "The newer bulbs use less electricity than the old ones.",
          "answers" => ["NOT GIVEN"],
          "explanation" => "Người viết để câu hỏi điện năng cho kỹ sư và không nêu ý kiến."
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
