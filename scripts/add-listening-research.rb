# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A walk around the research centre",
  "level" => "C1",
  "ieltsPart" => 2,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 70,
  "sortOrder" => 67,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Guide: Welcome to the research centre. I will label five places on the plan. You are standing at number 1, the reception, on the south side. Collect your visitor card here. The cafe beside the door is not on the plan.\nOn your left, number 2 is the archive. Files from before 1990 are kept there. The computers in the corridor search only the later records.\nNumber 3, in the middle, is the laboratory. Visitors may look through the glass, but they may not enter.\nOn your right, number 4 is the seminar room. This afternoon's discussion is for staff, not for visitors.\nStraight ahead, at the north end, number 5 is the lecture hall. The public talk starts at four, and a ticket from reception is enough.",
  "groups" => [
    {
      "type" => "MAP_LABELLING",
      "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/research-centre.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["reception"], "evidence" => "number 1, the reception" },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["archive"], "evidence" => "number 2 is the archive" },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["laboratory"], "evidence" => "Number 3, in the middle, is the laboratory" },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["seminar room"], "evidence" => "number 4 is the seminar room" },
        { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["lecture hall"], "evidence" => "number 5 is the lecture hall" }
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
