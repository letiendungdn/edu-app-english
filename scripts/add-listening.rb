# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACKS = [
  {
    "title" => "A table at the River Cafe",
    "level" => "A2",
    "ieltsPart" => 1,
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "durationSec" => 45,
    "sortOrder" => 40,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Staff: River Cafe, good morning.\nNam: Hello. I would like a table for Saturday.\nStaff: What name is the booking under?\nNam: Nam Tran.\nStaff: How many people?\nNam: Four.\nStaff: We can offer seven o'clock or half past eight.\nNam: Seven o'clock, please.\nStaff: May I take a phone number?\nNam: 0903 441 228.\nStaff: We will keep the table for fifteen minutes. If you arrive later, please call us.",
    "groups" => [
      {
        "type" => "FORM_COMPLETION",
        "instruction" => "Complete the form. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
        "wordLimit" => 2,
        "questions" => [
          { "number" => 1, "prompt" => "Day: {{blank}}", "answers" => ["Saturday"], "evidence" => "a table for Saturday" },
          { "number" => 2, "prompt" => "Name: {{blank}}", "answers" => ["Nam Tran"], "evidence" => "Nam Tran" },
          { "number" => 3, "prompt" => "Number of people: {{blank}}", "answers" => ["4", "four"], "evidence" => "Four" },
          { "number" => 4, "prompt" => "Time: {{blank}}", "answers" => ["7", "seven", "seven o'clock"], "evidence" => "Seven o'clock, please." },
          { "number" => 5, "prompt" => "The table is kept for {{blank}} minutes", "answers" => ["15", "fifteen"], "evidence" => "keep the table for fifteen minutes" }
        ]
      }
    ]
  },
  {
    "title" => "The station clock",
    "level" => "B1",
    "ieltsPart" => 2,
    "bandMin" => 4.0,
    "bandMax" => 5.5,
    "durationSec" => 70,
    "sortOrder" => 41,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Guide: Welcome to Central Station. Before we start the tour, a note about the clock above the main hall. The clock stopped last Tuesday after a storm. Engineers will repair it on Thursday morning, and the hall will stay open while they work.\nPlease use the clocks on the platforms, not the hall clock, until Friday. Trains are still on time. The repair will not close the ticket office. Lost property has moved for this week to the room beside the cafe, on your left as you face the platforms. It closes at six. If you lose a bag today, go there before six, and bring your ticket.",
    "groups" => [
      {
        "type" => "NOTE_COMPLETION",
        "instruction" => "Complete the notes. Write ONE WORD ONLY.",
        "wordLimit" => 1,
        "questions" => [
          { "number" => 1, "prompt" => "The hall clock stopped after a {{blank}}.", "answers" => ["storm"], "evidence" => "after a storm" },
          { "number" => 2, "prompt" => "Engineers will repair it on {{blank}} morning.", "answers" => ["Thursday"], "evidence" => "repair it on Thursday morning" },
          { "number" => 3, "prompt" => "Use the clocks on the {{blank}} until Friday.", "answers" => ["platforms"], "evidence" => "use the clocks on the platforms" },
          { "number" => 4, "prompt" => "Lost property is beside the {{blank}}.", "answers" => ["cafe"], "evidence" => "beside the cafe" },
          { "number" => 5, "prompt" => "Lost property closes at {{blank}}.", "answers" => ["six"], "evidence" => "It closes at six" }
        ]
      }
    ]
  },
  {
    "title" => "Why cities add salt to roads",
    "level" => "B2",
    "ieltsPart" => 4,
    "bandMin" => 5.0,
    "bandMax" => 6.5,
    "durationSec" => 80,
    "sortOrder" => 42,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Lecturer: When ice forms on a road, tyres lose their grip. Many cities spread salt because salt lowers the temperature at which water freezes. A thin layer of salty water stays liquid a few degrees below zero, so the ice does not bond to the road surface.\nSalt is cheap and easy to store, but it is not harmless. It eats into steel bridges and it washes into rivers, where it can harm freshwater plants. For that reason, some cities now mix salt with sand. The sand gives tyres something to grip, and crews can use less salt.\nThe mixture does not work in every storm. Below about minus ten degrees, ordinary road salt loses most of its effect, and crews switch to a different chemical. Drivers should still slow down. Salt makes a road safer. It does not make it dry.",
    "groups" => [
      {
        "type" => "NOTE_COMPLETION",
        "instruction" => "Complete the notes. Write NO MORE THAN TWO WORDS.",
        "wordLimit" => 2,
        "questions" => [
          { "number" => 1, "prompt" => "Salt lowers the temperature at which water {{blank}}.", "answers" => ["freezes"], "evidence" => "salt lowers the temperature at which water freezes" },
          { "number" => 2, "prompt" => "Salt can damage steel {{blank}}.", "answers" => ["bridges"], "evidence" => "It eats into steel bridges" },
          { "number" => 3, "prompt" => "Some cities mix salt with {{blank}}.", "answers" => ["sand"], "evidence" => "mix salt with sand" },
          { "number" => 4, "prompt" => "Ordinary salt is weak below about minus {{blank}} degrees.", "answers" => ["ten", "10"], "evidence" => "Below about minus ten degrees" },
          { "number" => 5, "prompt" => "Salt makes a road safer, but not {{blank}}.", "answers" => ["dry"], "evidence" => "It does not make it dry." }
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
