# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A call about the bike repair",
  "level" => "B1",
  "ieltsPart" => 1,
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "durationSec" => 65,
  "sortOrder" => 62,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Caller: Hello, is that the bike shop?\nMechanic: Yes. How can I help?\nCaller: My front brake is loose, the back light is broken, and the chain is dry. There is also a small hole in the front tyre, and the bell does not ring.\nMechanic: We can fix the brake and the back light today. The chain needs oil, but that is a job for tomorrow. The hole in the tyre is too small to repair, and we do not fit bells.\nCaller: What should I bring?\nMechanic: Bring the lock and the receipt. You do not need the old brake pads. Please do not bring the basket, because we take it off. And leave the helmet at home.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO problems can the shop fix today?",
          "answers" => ["A", "B"],
          "evidence" => "We can fix the brake and the back light today.",
          "options" => [
            { "key" => "A", "text" => "the loose brake" },
            { "key" => "B", "text" => "the broken back light" },
            { "key" => "C", "text" => "the dry chain" },
            { "key" => "D", "text" => "the hole in the tyre" },
            { "key" => "E", "text" => "the bell" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO things must the caller bring?",
          "answers" => ["A", "C"],
          "evidence" => "Bring the lock and the receipt.",
          "options" => [
            { "key" => "A", "text" => "the lock" },
            { "key" => "B", "text" => "the old brake pads" },
            { "key" => "C", "text" => "the receipt" },
            { "key" => "D", "text" => "the basket" },
            { "key" => "E", "text" => "the helmet" }
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
