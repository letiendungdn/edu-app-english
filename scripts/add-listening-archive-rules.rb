# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "Rules for the evening archive",
  "level" => "C1",
  "ieltsPart" => 2,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 70,
  "sortOrder" => 73,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Guide: Welcome to the evening archive. Visitors may enter two rooms. The reading room is open until nine, and the catalogue room is open for the card index. The store stays locked. The seminar room is for staff tonight, and the roof store is closed for repairs.\nYou must leave two things at the desk. Leave your bag, and leave your phone. You may keep a pencil. Keep your reader's card with you, because the door checks it. Coats can stay with you.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO rooms may visitors enter?",
          "answers" => ["A", "B"],
          "evidence" => "The reading room is open until nine, and the catalogue room is open for the card index.",
          "options" => [
            { "key" => "A", "text" => "the reading room" },
            { "key" => "B", "text" => "the catalogue room" },
            { "key" => "C", "text" => "the store" },
            { "key" => "D", "text" => "the seminar room" },
            { "key" => "E", "text" => "the roof store" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO things must visitors leave at the desk?",
          "answers" => ["A", "C"],
          "evidence" => "Leave your bag, and leave your phone.",
          "options" => [
            { "key" => "A", "text" => "a bag" },
            { "key" => "B", "text" => "a pencil" },
            { "key" => "C", "text" => "a phone" },
            { "key" => "D", "text" => "a reader's card" },
            { "key" => "E", "text" => "a coat" }
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
