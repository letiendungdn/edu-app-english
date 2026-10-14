# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACK = {
  "title" => "The Millford flood",
  "level" => "C1",
  "ieltsPart" => 4,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 80,
  "sortOrder" => 55,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => "Lecturer: Today's short talk is about the 2019 flood in Millford. I will name two causes, and two steps the council will take.\nThe flood had two causes. Heavy rain fell for three days, and a new car park covered the field that used to soak up water. The old bridge did not cause the flood. The bridge was high enough. A broken pump at the mill was repaired a week before the rain, so that was not a cause either.\nAfter the flood, some people asked for a higher bridge and for a dam upstream. The council will not build either of those. They will widen the drains under the high street, and they will turn the car park back into a field of grass. They will also keep the Saturday market where it is.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO things caused the Millford flood?",
          "answers" => ["A", "C"],
          "evidence" => "Heavy rain fell for three days, and a new car park covered the field",
          "options" => [
            { "key" => "A", "text" => "three days of heavy rain" },
            { "key" => "B", "text" => "the old bridge" },
            { "key" => "C", "text" => "the new car park" },
            { "key" => "D", "text" => "a broken pump" },
            { "key" => "E", "text" => "the Saturday market" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO steps will the council take?",
          "answers" => ["C", "D"],
          "evidence" => "They will widen the drains under the high street, and they will turn the car park back into a field of grass.",
          "options" => [
            { "key" => "A", "text" => "build a higher bridge" },
            { "key" => "B", "text" => "build a dam upstream" },
            { "key" => "C", "text" => "widen the drains" },
            { "key" => "D", "text" => "turn the car park into grass" },
            { "key" => "E", "text" => "move the Saturday market" }
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
