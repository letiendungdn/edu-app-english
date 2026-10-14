# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A visit to the harbour",
  "level" => "B1",
  "ieltsPart" => 2,
  "bandMin" => 4.5,
  "bandMax" => 6.0,
  "durationSec" => 70,
  "sortOrder" => 52,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Guide: Welcome to the Saturday harbour walk. I will tell you two things you may bring, and two places that are closed today.\nYou may bring a hat and a bottle of water. Please leave bikes at the gate. Dogs are not allowed on the boats. Food from outside is fine, but please do not bring glass bottles.\nThe ticket office is closed today. Buy tickets on the boat. The fish shop is also closed, because the boats came in late. The cafe is open until four. The lighthouse steps are open, and the small museum is open until three.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO things may visitors bring?",
          "answers" => ["A", "D"],
          "evidence" => "You may bring a hat and a bottle of water.",
          "options" => [
            { "key" => "A", "text" => "a hat" },
            { "key" => "B", "text" => "a bike" },
            { "key" => "C", "text" => "a dog" },
            { "key" => "D", "text" => "a bottle of water" },
            { "key" => "E", "text" => "a glass bottle" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO places are closed today?",
          "answers" => ["A", "C"],
          "evidence" => "The ticket office is closed today. The fish shop is also closed",
          "options" => [
            { "key" => "A", "text" => "the ticket office" },
            { "key" => "B", "text" => "the cafe" },
            { "key" => "C", "text" => "the fish shop" },
            { "key" => "D", "text" => "the lighthouse steps" },
            { "key" => "E", "text" => "the small museum" }
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
