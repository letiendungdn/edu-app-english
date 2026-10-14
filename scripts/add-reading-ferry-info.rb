# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "How the ferry timetable changed",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Transport",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 52,
  "content" => "A\nFor twenty years the town ferry left the quay every two hours, beginning at half past eight. The crossing took twenty minutes, and the same two boats covered the whole day. That pattern was simple to remember, and the printed card in the shelter barely changed from one year to the next.\n\nB\nRegular travellers asked for a change because the half-past-eight boat reached the station after the fast train had gone. Office workers were the main group behind the request. Weekend visitors were content with the old gaps, and the council's own survey found that tourists rarely mentioned the timetable at all.\n\nC\nThe new timetable started in March. Boats now leave every hour, and the first one casts off at seven. The last boat back is at seven in the evening on weekdays. A return ticket still costs the same as before.\n\nD\nThe seven o'clock departure does not run in January. Short days and a thin morning crew make that first sailing unsafe, so January passengers use the eight o'clock boat instead. The hourly pattern returns in February.",
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
        {
          "number" => 1,
          "prompt" => "how often the old boats left",
          "answers" => ["A"],
          "evidence" => "left the quay every two hours"
        },
        {
          "number" => 2,
          "prompt" => "why regular travellers asked for a change",
          "answers" => ["B"],
          "evidence" => "the half-past-eight boat reached the station after the fast train had gone"
        },
        {
          "number" => 3,
          "prompt" => "the time the first boat leaves now",
          "answers" => ["C"],
          "evidence" => "the first one casts off at seven"
        },
        {
          "number" => 4,
          "prompt" => "a month when the earliest boat does not sail",
          "answers" => ["D"],
          "evidence" => "The seven o'clock departure does not run in January."
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
