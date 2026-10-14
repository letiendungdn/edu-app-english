# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Grants for the town museum",
  "level" => "C1",
  "ieltsPart" => 3,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 75,
  "sortOrder" => 51,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Anya: The museum can fund only two of the five proposals this year.\nBen: The roof repair can wait. The surveyor said the tiles will last another winter.\nAnya: The children's workshop is cheap, and the schools have already booked dates, so that one stays. The evening lectures should stay too. Last year's talks were full, and the speakers have agreed to come for free.\nBen: The new cafe would need a kitchen we cannot afford. The digital archive is useful, but the grant rules say the university must pay for digitising, not us.\nAnya: So we fund the workshop and the lectures.\nBen: Then the cuts. We can drop the printed guidebook. Most visitors use their phones. We should also stop paying a guide on Sundays. Volunteers already cover that day.\nAnya: I want to keep the late opening on Thursday, and I want to keep the free coat check. Both bring people in when it rains.\nBen: Agreed. We cut the guidebook and the Sunday guide, and we leave Thursday and the coat check as they are.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO projects will the museum fund?",
          "answers" => ["B", "C"],
          "evidence" => "we fund the workshop and the lectures",
          "options" => [
            { "key" => "A", "text" => "roof repair" },
            { "key" => "B", "text" => "a children's workshop" },
            { "key" => "C", "text" => "evening lectures" },
            { "key" => "D", "text" => "a new cafe" },
            { "key" => "E", "text" => "a digital archive" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO costs will Anya and Ben cut?",
          "answers" => ["A", "B"],
          "evidence" => "We cut the guidebook and the Sunday guide",
          "options" => [
            { "key" => "A", "text" => "the printed guidebook" },
            { "key" => "B", "text" => "the paid Sunday guide" },
            { "key" => "C", "text" => "Thursday late opening" },
            { "key" => "D", "text" => "the free coat check" },
            { "key" => "E", "text" => "speaker fees" }
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
