# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "The end of the night buses",
  "level" => "C1",
  "ieltsPart" => 4,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 80,
  "sortOrder" => 56,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lecturer: The council has ended the night buses, and the report gives two reasons. After eleven, most buses carried fewer than eight passengers. The depot also cannot staff a third night shift. The fare did not change, so price was not a cause. Roadworks on the ring road finished in May, before the decision. Complaints about noise were few, and the report sets them aside.\nTwo services will take the place of those buses. A shared taxi will leave the station every half hour until one in the morning. On Sundays, the first train will leave at six instead of seven. The old night route will not return. The council will not add a tram, and it will not keep a bus on Friday nights only.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO reasons does the lecturer give for ending the night buses?",
          "answers" => ["A", "B"],
          "evidence" => "fewer than eight passengers. The depot also cannot staff a third night shift.",
          "options" => [
            { "key" => "A", "text" => "very few passengers after eleven" },
            { "key" => "B", "text" => "no staff for another night shift" },
            { "key" => "C", "text" => "a rise in the fare" },
            { "key" => "D", "text" => "roadworks on the ring road" },
            { "key" => "E", "text" => "complaints about noise" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO services will replace the night buses?",
          "answers" => ["A", "C"],
          "evidence" => "A shared taxi will leave the station every half hour until one. On Sundays, the first train will leave at six",
          "options" => [
            { "key" => "A", "text" => "a shared taxi from the station" },
            { "key" => "B", "text" => "the old night route" },
            { "key" => "C", "text" => "an earlier Sunday train" },
            { "key" => "D", "text" => "a new tram" },
            { "key" => "E", "text" => "a Friday-night bus" }
          ]
        }
      ]
    }
  ]
}.freeze

data = JSON.parse(File.read(PATH))
titles = data["tracks"].map { |item| item["title"] }
if titles.include?(TRACK["title"])
  warn "skip #{TRACK["title"]}"
else
  data["tracks"] << TRACK
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "tracks=#{data["tracks"].size}"
