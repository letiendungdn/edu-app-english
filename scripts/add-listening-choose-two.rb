# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Stalls for the school fair",
  "level" => "B1",
  "ieltsPart" => 3,
  "bandMin" => 4.5,
  "bandMax" => 6.0,
  "durationSec" => 70,
  "sortOrder" => 49,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Mai: The school fair needs two stalls from our class. The list has five ideas.\nNam: A cake stall takes too long to bake. A book stall is fine, and so is a plant stall. The game stall needs prizes we do not have. The photo stall needs a camera from the office, and the office said no.\nMai: So we take the book stall and the plant stall.\nNam: Yes. Now the times. Friday at four is the football match, so the hall is full. Saturday morning is free, and Saturday afternoon is free too. Sunday is the teachers' meeting, so the hall is closed.\nMai: Then we run the stalls on Saturday morning and Saturday afternoon.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO stalls do Mai and Nam choose?",
          "answers" => ["B", "C"],
          "evidence" => "we take the book stall and the plant stall",
          "options" => [
            { "key" => "A", "text" => "a cake stall" },
            { "key" => "B", "text" => "a book stall" },
            { "key" => "C", "text" => "a plant stall" },
            { "key" => "D", "text" => "a game stall" },
            { "key" => "E", "text" => "a photo stall" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO times are free for the stalls?",
          "answers" => ["B", "C"],
          "evidence" => "Saturday morning is free, and Saturday afternoon is free too",
          "options" => [
            { "key" => "A", "text" => "Friday at four" },
            { "key" => "B", "text" => "Saturday morning" },
            { "key" => "C", "text" => "Saturday afternoon" },
            { "key" => "D", "text" => "Sunday morning" },
            { "key" => "E", "text" => "Sunday afternoon" }
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
