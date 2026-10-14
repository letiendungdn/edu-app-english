# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "A call about the swimming class",
  "level" => "A2",
  "ieltsPart" => 1,
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "durationSec" => 65,
  "sortOrder" => 53,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Caller: Hello, is that the sports centre?\nReceptionist: Yes. How can I help?\nCaller: I want to know two things I should bring to the swimming class, and two times the pool is closed.\nReceptionist: Bring a towel and a swim hat. You can hire goggles here, so you do not need to bring those. Please do not bring food into the pool hall, and leave watches in a locker, not on the bench.\nThe pool is closed on Monday morning for cleaning, and on Friday evening for the club. It is open on Saturday afternoon and on Sunday morning. The shop beside the pool is closed on Wednesday, but the pool itself is open that day.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO things should the caller bring?",
          "answers" => ["A", "C"],
          "evidence" => "Bring a towel and a swim hat.",
          "options" => [
            { "key" => "A", "text" => "a towel" },
            { "key" => "B", "text" => "goggles" },
            { "key" => "C", "text" => "a swim hat" },
            { "key" => "D", "text" => "food" },
            { "key" => "E", "text" => "a watch" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO times is the pool closed?",
          "answers" => ["A", "C"],
          "evidence" => "closed on Monday morning for cleaning, and on Friday evening for the club",
          "options" => [
            { "key" => "A", "text" => "Monday morning" },
            { "key" => "B", "text" => "Saturday afternoon" },
            { "key" => "C", "text" => "Friday evening" },
            { "key" => "D", "text" => "Sunday morning" },
            { "key" => "E", "text" => "Wednesday" }
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
