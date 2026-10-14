# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACKS = [
  {
    "title" => "Plans for the riverside park",
    "level" => "B1",
    "ieltsPart" => 3,
    "bandMin" => 4.5,
    "bandMax" => 6.0,
    "durationSec" => 75,
    "sortOrder" => 46,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Lan: The council wants ideas before they rebuild the riverside park. I read the leaflet. They will keep the playground, and they have already rejected a car park.\nMinh: Good. Parents asked for two things more than anything else: a fence around the playground, and lights along the path. A cafe would be nice, but it was near the bottom of the list. Nobody supported a stage for concerts.\nLan: For the path itself, the leaflet offers wood chips or smooth stone. Wood chips get slippery, so I would choose stone, and I would add benches every fifty metres.\nMinh: Agreed. And booking the picnic lawn should stay free for schools on weekday mornings. Companies can pay to use it after three. Weekends should remain first come, first served.\nLan: Then our two recommendations are the fence and the path lights. I will send that today.",
    "groups" => [
      {
        "type" => "MULTIPLE_CHOICE_MULTI",
        "instruction" => "Choose TWO letters, A-E.",
        "questions" => [
          {
            "number" => 1,
            "prompt" => "Which TWO ideas do parents want most?",
            "answers" => ["A", "C"],
            "evidence" => "a fence around the playground, and lights along the path",
            "options" => [
              { "key" => "A", "text" => "a fence around the playground" },
              { "key" => "B", "text" => "a small cafe" },
              { "key" => "C", "text" => "lights along the path" },
              { "key" => "D", "text" => "a stage for concerts" },
              { "key" => "E", "text" => "a car park" }
            ]
          },
          {
            "number" => 2,
            "prompt" => "Which TWO points do Lan and Minh agree on?",
            "answers" => ["B", "E"],
            "evidence" => "I would choose stone, and I would add benches",
            "options" => [
              { "key" => "A", "text" => "a surface of wood chips" },
              { "key" => "B", "text" => "a surface of stone" },
              { "key" => "C", "text" => "no benches" },
              { "key" => "D", "text" => "benches every twenty metres" },
              { "key" => "E", "text" => "benches every fifty metres" }
            ]
          }
        ]
      }
    ]
  },
  {
    "title" => "The library late pass",
    "level" => "A2",
    "ieltsPart" => 1,
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "durationSec" => 50,
    "sortOrder" => 47,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Librarian: Central Library, how can I help?\nHoa: I would like a late pass for Thursday.\nLibrarian: Which name is on your card?\nHoa: Hoa Le.\nLibrarian: The late room is the reading room on the second floor. It stays open until nine. Please bring the pass and a bottle of water. Food is not allowed. The pass costs nothing for students.",
    "groups" => [
      {
        "type" => "FORM_COMPLETION",
        "instruction" => "Complete the form. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
        "wordLimit" => 2,
        "questions" => [
          { "number" => 1, "prompt" => "Day: {{blank}}", "answers" => ["Thursday"], "evidence" => "a late pass for Thursday" },
          { "number" => 2, "prompt" => "Name: {{blank}}", "answers" => ["Hoa Le"], "evidence" => "Hoa Le" },
          { "number" => 3, "prompt" => "Room: {{blank}} room", "answers" => ["reading"], "evidence" => "the reading room" },
          { "number" => 4, "prompt" => "Floor: {{blank}}", "answers" => ["2", "second", "the second"], "evidence" => "on the second floor" },
          { "number" => 5, "prompt" => "Closes at: {{blank}}", "answers" => ["9", "nine"], "evidence" => "open until nine" }
        ]
      }
    ]
  }
].freeze

data = JSON.parse(File.read(PATH))
titles = data["tracks"].map { |item| item["title"] }
added = 0
TRACKS.each do |track|
  if titles.include?(track["title"])
    warn "skip #{track["title"]}"
    next
  end
  data["tracks"] << track
  added += 1
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "added=#{added} tracks=#{data["tracks"].size}"
