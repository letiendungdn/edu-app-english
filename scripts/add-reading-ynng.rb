# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Leaf blowers on city streets",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Town planning",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 50,
  "content" => "Leaf blowers have become a regular part of city maintenance, and the present free-for-all is a mistake. Crews use the machines at all hours, including Sunday mornings, when the noise carries straight into bedrooms.\nI do not accept the claim that electric models settle the matter. They are quieter than petrol ones, and they avoid the fumes, but they are not silent. A neighbour can still be woken by one.\nA total ban appeals to some campaigners. That would be the wrong remedy. Crews would simply move the same work to the weekend, when more residents are at home. The better rule is to allow the machines on weekday mornings only, and to stop them by noon.\nCouncils that have tried this rule report fewer complaints. Whether an electric model costs less to buy than a petrol one is a question for the purchasing office. It is not part of the argument here.",
  "groups" => [
    {
      "type" => "YES_NO_NOT_GIVEN",
      "instruction" => "Do the following statements agree with the claims of the writer? Write YES, NO or NOT GIVEN.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Leaf blowers should be limited to weekday mornings.",
          "answers" => ["YES"],
          "evidence" => "The better rule is to allow the machines on weekday mornings only"
        },
        {
          "number" => 2,
          "prompt" => "Electric leaf blowers are silent.",
          "answers" => ["NO"],
          "evidence" => "they are not silent"
        },
        {
          "number" => 3,
          "prompt" => "A total ban is the best remedy.",
          "answers" => ["NO"],
          "evidence" => "That would be the wrong remedy."
        },
        {
          "number" => 4,
          "prompt" => "Electric models cost less to buy than petrol models.",
          "answers" => ["NOT GIVEN"],
          "explanation" => "Người viết để câu hỏi giá mua cho phòng mua sắm và không nêu ý kiến."
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
