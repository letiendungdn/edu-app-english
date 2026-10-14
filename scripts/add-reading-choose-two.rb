# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGE = {
  "title" => "Lights on the river path",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Town planning",
  "bandMin" => 5.5,
  "bandMax" => 6.5,
  "estimatedMin" => 6,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 45,
  "content" => "The council has published a short report on the river path. Two problems stand out. The path is dark after eight, and the wooden benches stay wet for days after rain. Cyclists also ride too fast, but the report says speed is a separate matter and was not one of the two problems measured this year. Litter bins were emptied on time, so waste was not listed either.\nThe council will make two changes before June. It will fit low lamps every thirty metres, and it will replace the wooden benches with metal ones that dry quickly. It will not ban bicycles, and it will not close the path at night. A cafe at the north gate was suggested, but the report leaves that idea for next year.",
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE_MULTI",
      "instruction" => "Choose TWO letters, A-E.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Which TWO problems does the river-path report name?",
          "answers" => ["A", "B"],
          "evidence" => "The path is dark after eight, and the wooden benches stay wet for days after rain.",
          "options" => [
            { "key" => "A", "text" => "The path is dark after eight." },
            { "key" => "B", "text" => "The benches stay wet after rain." },
            { "key" => "C", "text" => "Cyclists ride too fast." },
            { "key" => "D", "text" => "The litter bins overflow." },
            { "key" => "E", "text" => "The north gate is locked." }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Which TWO changes will happen before June?",
          "answers" => ["A", "B"],
          "evidence" => "It will fit low lamps every thirty metres, and it will replace the wooden benches with metal ones",
          "options" => [
            { "key" => "A", "text" => "low lamps every thirty metres" },
            { "key" => "B", "text" => "metal benches" },
            { "key" => "C", "text" => "a ban on bicycles" },
            { "key" => "D", "text" => "closing the path at night" },
            { "key" => "E", "text" => "a cafe at the north gate" }
          ]
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
