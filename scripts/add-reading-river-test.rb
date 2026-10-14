# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Testing the river water",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Environment",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 8,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 55,
  "content" => "A short study explains how the council tests the river each week. A worker collects a sample from the bridge at eight in the morning. The bottle is sealed at once. The sample is kept cool in a box until it reaches the lab, because warm water changes the result.\nAt the lab, staff check the sample for bacteria. They do not test for oil at this stage. On Friday the council publishes the result on its website. A poor result closes the swimming beach, but it does not stop the ferry.",
  "groups" => [
    {
      "type" => "FLOW_CHART_COMPLETION",
      "instruction" => "Complete the flow chart. Write ONE WORD ONLY from the passage for each answer.",
      "wordLimit" => 1,
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Collect a {{blank}} from the bridge.",
          "answers" => ["sample"],
          "evidence" => "A worker collects a sample from the bridge"
        },
        {
          "number" => 2,
          "prompt" => "Keep the sample {{blank}} in a box.",
          "answers" => ["cool"],
          "evidence" => "The sample is kept cool in a box"
        },
        {
          "number" => 3,
          "prompt" => "Staff check the sample for {{blank}}.",
          "answers" => ["bacteria"],
          "evidence" => "staff check the sample for bacteria"
        },
        {
          "number" => 4,
          "prompt" => "The council publishes the result on {{blank}}.",
          "answers" => ["Friday"],
          "evidence" => "On Friday the council publishes the result"
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
