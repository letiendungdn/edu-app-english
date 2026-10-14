# frozen_string_literal: true

require "json"

LISTENING = "backend/src/main/resources/content/listening.json"
READING = "backend/src/main/resources/content/reading.json"

TRACKS = [
  {
    "title" => "Who planned the school show",
    "level" => "B1",
    "ieltsPart" => 4,
    "bandMin" => 4.0,
    "bandMax" => 5.5,
    "durationSec" => 70,
    "sortOrder" => 77,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Teacher: This short talk is about the people who planned the school show. Mia chooses the songs. She does not sell tickets. Tom sells the tickets at the door. Sara paints the posters. Jack checks the lights before the show. Nina wanted to sing, but the choir is already full. Ben is away this week.",
    "groups" => [
      {
        "type" => "MATCHING_FEATURES",
        "instruction" => "Who does each job? Choose FOUR answers from the box and write the correct letter, A-D.",
        "options" => [
          { "key" => "A", "text" => "Mia" },
          { "key" => "B", "text" => "Tom" },
          { "key" => "C", "text" => "Sara" },
          { "key" => "D", "text" => "Jack" }
        ],
        "questions" => [
          { "number" => 1, "prompt" => "chooses the songs", "answers" => ["A"], "evidence" => "Mia chooses the songs." },
          { "number" => 2, "prompt" => "sells the tickets at the door", "answers" => ["B"], "evidence" => "Tom sells the tickets at the door." },
          { "number" => 3, "prompt" => "paints the posters", "answers" => ["C"], "evidence" => "Sara paints the posters." },
          { "number" => 4, "prompt" => "checks the lights", "answers" => ["D"], "evidence" => "Jack checks the lights before the show." }
        ]
      }
    ]
  },
  {
    "title" => "A call about a flat viewing",
    "level" => "B2",
    "ieltsPart" => 1,
    "bandMin" => 5.5,
    "bandMax" => 6.5,
    "durationSec" => 70,
    "sortOrder" => 78,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Agent: Good afternoon. How can I help?\nCaller: I would like to view the flat. My surname is Brooks.\nAgent: Thank you, Ms Brooks. Thursday is full. The next viewing is on Friday.\nCaller: What time on Friday?\nAgent: Not at five. The five o'clock slot has gone. Yours is at six.\nCaller: Is the flat on Hill Street?\nAgent: No. It is on River Street. I will meet you there. My name is Nina. The owner will not be at home.",
    "groups" => [
      {
        "type" => "FORM_COMPLETION",
        "instruction" => "Complete the form. Write ONE WORD AND/OR A NUMBER for each answer.",
        "wordLimit" => 1,
        "questions" => [
          { "number" => 1, "prompt" => "Surname: {{blank}}", "answers" => ["Brooks"], "evidence" => "My surname is Brooks." },
          { "number" => 2, "prompt" => "Day: {{blank}}", "answers" => ["Friday"], "evidence" => "The next viewing is on Friday." },
          { "number" => 3, "prompt" => "Time: {{blank}}", "answers" => ["six", "6"], "evidence" => "Yours is at six." },
          { "number" => 4, "prompt" => "Street: {{blank}}", "answers" => ["River"], "evidence" => "It is on River Street." },
          { "number" => 5, "prompt" => "Agent: {{blank}}", "answers" => ["Nina"], "evidence" => "My name is Nina." }
        ]
      }
    ]
  },
  {
    "title" => "A call about the conference badge",
    "level" => "C1",
    "ieltsPart" => 1,
    "bandMin" => 6.0,
    "bandMax" => 7.5,
    "durationSec" => 70,
    "sortOrder" => 79,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Clerk: Conference office. How can I help?\nCaller: I need a badge for Friday. My surname is Hale.\nClerk: Thank you, Dr Hale. Your session is in room fourteen, not room forty.\nCaller: Does the fee include dinner?\nClerk: No. Dinner is extra. Lunch is included.\nCaller: Where do I collect the badge?\nClerk: At the desk in the lobby. The hall does not issue badges.",
    "groups" => [
      {
        "type" => "FORM_COMPLETION",
        "instruction" => "Complete the form. Write ONE WORD AND/OR A NUMBER for each answer.",
        "wordLimit" => 1,
        "questions" => [
          { "number" => 1, "prompt" => "Surname: {{blank}}", "answers" => ["Hale"], "evidence" => "My surname is Hale." },
          { "number" => 2, "prompt" => "Day: {{blank}}", "answers" => ["Friday"], "evidence" => "I need a badge for Friday." },
          { "number" => 3, "prompt" => "Room: {{blank}}", "answers" => ["fourteen", "14"], "evidence" => "Your session is in room fourteen" },
          { "number" => 4, "prompt" => "Meal included: {{blank}}", "answers" => ["lunch"], "evidence" => "Lunch is included." },
          { "number" => 5, "prompt" => "Collect the badge at the {{blank}}", "answers" => ["desk"], "evidence" => "At the desk in the lobby." }
        ]
      }
    ]
  }
].freeze

PASSAGES = [
  {
    "title" => "The village hall floor",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "Town",
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "estimatedMin" => 6,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 67,
    "content" => "The plan shows the village hall. Point 1, at the south edge, is the entrance. Point 2, on the west side, is the kitchen. Point 3, in the middle, is the hall. Point 4, on the east side, is the office. Point 5, at the north end, is the stage. The cloakroom by the door is not on the plan.",
    "groups" => [
      {
        "type" => "MAP_LABELLING",
        "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
        "wordLimit" => 2,
        "imageUrl" => "/api/media/village-hall.svg",
        "questions" => [
          { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["entrance"], "evidence" => "Point 1, at the south edge, is the entrance." },
          { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["kitchen"], "evidence" => "Point 2, on the west side, is the kitchen." },
          { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["hall"], "evidence" => "Point 3, in the middle, is the hall." },
          { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["office"], "evidence" => "Point 4, on the east side, is the office." },
          { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["stage"], "evidence" => "Point 5, at the north end, is the stage." }
        ]
      }
    ]
  },
  {
    "title" => "The Saturday bus to the beach",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "Transport",
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "estimatedMin" => 6,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 68,
    "content" => "The Saturday bus to the beach leaves at nine. It does not leave at eight. It leaves from the station, not from the market. An adult ticket costs three pounds. Children pay one pound. The bus does not stop at the zoo. It stops at the pier.",
    "groups" => [
      {
        "type" => "MULTIPLE_CHOICE",
        "instruction" => "Choose the correct letter, A, B or C.",
        "questions" => [
          {
            "number" => 1,
            "prompt" => "What time does the bus leave?",
            "answers" => ["B"],
            "evidence" => "leaves at nine",
            "options" => [
              { "key" => "A", "text" => "at eight" },
              { "key" => "B", "text" => "at nine" },
              { "key" => "C", "text" => "at ten" }
            ]
          },
          {
            "number" => 2,
            "prompt" => "Where does the bus leave from?",
            "answers" => ["A"],
            "evidence" => "It leaves from the station",
            "options" => [
              { "key" => "A", "text" => "the station" },
              { "key" => "B", "text" => "the market" },
              { "key" => "C", "text" => "the zoo" }
            ]
          },
          {
            "number" => 3,
            "prompt" => "How much is an adult ticket?",
            "answers" => ["C"],
            "evidence" => "An adult ticket costs three pounds.",
            "options" => [
              { "key" => "A", "text" => "one pound" },
              { "key" => "B", "text" => "two pounds" },
              { "key" => "C", "text" => "three pounds" }
            ]
          },
          {
            "number" => 4,
            "prompt" => "Where does the bus stop?",
            "answers" => ["B"],
            "evidence" => "It stops at the pier.",
            "options" => [
              { "key" => "A", "text" => "at the zoo" },
              { "key" => "B", "text" => "at the pier" },
              { "key" => "C", "text" => "at the market" }
            ]
          }
        ]
      }
    ]
  },
  {
    "title" => "A note about the school bell",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "School",
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "estimatedMin" => 6,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 69,
    "content" => "The school bell should ring at nine. A bell at half past eight is too early, and children would miss the first lesson if they arrived late. The bell should stay loud. A quiet bell is a bad idea, because people at the far gate would not hear it.",
    "groups" => [
      {
        "type" => "YES_NO_NOT_GIVEN",
        "instruction" => "Do the following statements agree with the claims of the writer? Write YES, NO or NOT GIVEN.",
        "questions" => [
          { "number" => 1, "prompt" => "The bell should ring at nine.", "answers" => ["YES"], "evidence" => "The school bell should ring at nine." },
          { "number" => 2, "prompt" => "The bell should ring at half past eight.", "answers" => ["NO"], "evidence" => "A bell at half past eight is too early" },
          { "number" => 3, "prompt" => "A quiet bell would be better.", "answers" => ["NO"], "evidence" => "A quiet bell is a bad idea" },
          { "number" => 4, "prompt" => "Most teachers want a new bell.", "answers" => ["NOT GIVEN"], "explanation" => "Bài không nói ý kiến của giáo viên." }
        ]
      }
    ]
  },
  {
    "title" => "The new town market",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "Town",
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "estimatedMin" => 6,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 70,
    "content" => "A\nThe market moved from the square to the river car park in May.\n\nB\nIt opens on Friday evening. It does not open on Sunday morning.\n\nC\nFood stalls are at the north end. Clothes are at the south end.\n\nD\nThe council pays for the lights. Stall holders pay for their own tables.",
    "groups" => [
      {
        "type" => "MATCHING_HEADINGS",
        "instruction" => "Choose the correct heading for each paragraph from the list of headings below.",
        "options" => [
          { "key" => "i", "text" => "a change of place" },
          { "key" => "ii", "text" => "when the market opens" },
          { "key" => "iii", "text" => "where the food stalls are" },
          { "key" => "iv", "text" => "who pays for the lights" },
          { "key" => "v", "text" => "the price of the food" },
          { "key" => "vi", "text" => "a Sunday opening" }
        ],
        "questions" => [
          { "number" => 1, "prompt" => "Paragraph A", "answers" => ["i"], "evidence" => "moved from the square to the river car park" },
          { "number" => 2, "prompt" => "Paragraph B", "answers" => ["ii"], "evidence" => "It opens on Friday evening." },
          { "number" => 3, "prompt" => "Paragraph C", "answers" => ["iii"], "evidence" => "Food stalls are at the north end." },
          { "number" => 4, "prompt" => "Paragraph D", "answers" => ["iv"], "evidence" => "The council pays for the lights." }
        ]
      }
    ]
  },
  {
    "title" => "Rules for the town pool",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "Free time",
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "estimatedMin" => 6,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 71,
    "content" => "The town pool is open from eight in the morning to six in the evening. Children under five must stay with a parent. They may not swim alone. Goggles are allowed. Food is not allowed in the water. The notice does not give a price.",
    "groups" => [
      {
        "type" => "TRUE_FALSE_NOT_GIVEN",
        "instruction" => "Do the following statements agree with the information? Write TRUE, FALSE or NOT GIVEN.",
        "questions" => [
          { "number" => 1, "prompt" => "The pool opens at eight in the morning.", "answers" => ["TRUE"], "evidence" => "open from eight in the morning" },
          { "number" => 2, "prompt" => "Children under five may swim alone.", "answers" => ["FALSE"], "evidence" => "They may not swim alone." },
          { "number" => 3, "prompt" => "Swimmers may wear goggles.", "answers" => ["TRUE"], "evidence" => "Goggles are allowed." },
          { "number" => 4, "prompt" => "A swim costs three pounds.", "answers" => ["NOT GIVEN"], "explanation" => "Thông báo không nêu giá." }
        ]
      }
    ]
  },
  {
    "title" => "Why the old mill closed",
    "level" => "B2",
    "module" => "ACADEMIC",
    "topic" => "History",
    "bandMin" => 5.5,
    "bandMax" => 6.5,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 72,
    "content" => "The old mill closed in 1994. The river was too low for the wheel, so the stones could not turn. The last product was flour. Bread was baked in the town, not at the mill. The building is now a museum. Visitors enter from the yard. The shop sells postcards. It does not sell flour.",
    "groups" => [
      {
        "type" => "SUMMARY_COMPLETION",
        "instruction" => "Complete the summary. Write ONE WORD AND/OR A NUMBER from the passage for each answer.",
        "wordLimit" => 1,
        "questions" => [
          { "number" => 1, "prompt" => "The mill closed in {{blank}}.", "answers" => ["1994"], "evidence" => "closed in 1994" },
          { "number" => 2, "prompt" => "The river was too {{blank}} for the wheel.", "answers" => ["low"], "evidence" => "The river was too low for the wheel" },
          { "number" => 3, "prompt" => "The last product was {{blank}}.", "answers" => ["flour"], "evidence" => "The last product was flour." },
          { "number" => 4, "prompt" => "The building is now a {{blank}}.", "answers" => ["museum"], "evidence" => "The building is now a museum." },
          { "number" => 5, "prompt" => "Visitors enter from the {{blank}}.", "answers" => ["yard"], "evidence" => "Visitors enter from the yard." }
        ]
      }
    ]
  },
  {
    "title" => "Parts of a rain gauge",
    "level" => "B2",
    "module" => "ACADEMIC",
    "topic" => "Science",
    "bandMin" => 5.5,
    "bandMax" => 6.5,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 73,
    "content" => "The diagram shows a simple rain gauge. Part 1 is the lid. It keeps leaves out. Part 2 is the funnel. Rain runs through it. Part 3 is the tube. It carries the water down. Part 4 is the jar. The jar holds the water so it can be measured. The stand under the jar is not labelled.",
    "groups" => [
      {
        "type" => "DIAGRAM_LABEL",
        "instruction" => "Label the diagram. Write ONE WORD ONLY for each answer.",
        "wordLimit" => 1,
        "imageUrl" => "/api/media/rain-gauge.svg",
        "questions" => [
          { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["lid"], "evidence" => "Part 1 is the lid." },
          { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["funnel"], "evidence" => "Part 2 is the funnel." },
          { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["tube"], "evidence" => "Part 3 is the tube." },
          { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["jar"], "evidence" => "Part 4 is the jar." }
        ]
      }
    ]
  },
  {
    "title" => "Three nights at the town theatre",
    "level" => "B2",
    "module" => "ACADEMIC",
    "topic" => "Arts",
    "bandMin" => 5.5,
    "bandMax" => 6.5,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 74,
    "content" => "The town theatre published its weekend list. On Friday there is a play. It starts at seven, and a ticket costs twelve pounds. On Saturday there is a concert. It starts at eight, and a ticket costs fifteen pounds. On Sunday there is a film. It starts at six, and a ticket costs eight pounds. The Friday event is not a concert.",
    "groups" => [
      {
        "type" => "TABLE_COMPLETION",
        "instruction" => "Complete the table. Write ONE WORD AND/OR A NUMBER.",
        "wordLimit" => 1,
        "questions" => [
          { "number" => 1, "prompt" => "Friday — start: {{blank}}", "answers" => ["seven", "7"], "evidence" => "It starts at seven" },
          { "number" => 2, "prompt" => "Friday — price: {{blank}}", "answers" => ["twelve", "12"], "evidence" => "a ticket costs twelve pounds" },
          { "number" => 3, "prompt" => "Saturday — event: {{blank}}", "answers" => ["concert"], "evidence" => "On Saturday there is a concert." },
          { "number" => 4, "prompt" => "Sunday — start: {{blank}}", "answers" => ["six", "6"], "evidence" => "It starts at six" },
          { "number" => 5, "prompt" => "Sunday — price: {{blank}}", "answers" => ["eight", "8"], "evidence" => "a ticket costs eight pounds" }
        ]
      }
    ]
  },
  {
    "title" => "Should the harbour stay open in winter",
    "level" => "C1",
    "module" => "ACADEMIC",
    "topic" => "Transport",
    "bandMin" => 6.0,
    "bandMax" => 7.5,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 75,
    "content" => "The winter ferry from the harbour carries hospital staff who finish after the last bus. Closing the harbour in January would remove that crossing. A closure would save fuel, yet the ferry matters more than the fuel saved. The harbour should stay open through January. This note does not discuss the harbour in the next town.",
    "groups" => [
      {
        "type" => "TRUE_FALSE_NOT_GIVEN",
        "instruction" => "Do the following statements agree with the information in the passage? Write TRUE, FALSE or NOT GIVEN.",
        "questions" => [
          { "number" => 1, "prompt" => "Hospital staff use the winter ferry.", "answers" => ["TRUE"], "evidence" => "carries hospital staff" },
          { "number" => 2, "prompt" => "The harbour should close in January.", "answers" => ["FALSE"], "evidence" => "The harbour should stay open through January." },
          { "number" => 3, "prompt" => "The writer thinks the ferry matters more than the fuel saved.", "answers" => ["TRUE"], "evidence" => "the ferry matters more than the fuel saved" },
          { "number" => 4, "prompt" => "The next town closes its harbour in winter.", "answers" => ["NOT GIVEN"], "explanation" => "Bài không nói về cảng của thị trấn bên cạnh." }
        ]
      }
    ]
  }
].freeze

def append(path, key, items)
  data = JSON.parse(File.read(path))
  titles = data[key].map { |item| item["title"] }
  items.each do |item|
    if titles.include?(item["title"])
      warn "skip #{item["title"]}"
    else
      data[key] << item
      titles << item["title"]
    end
  end
  File.write(path, JSON.pretty_generate(data) + "\n")
  puts "#{key}=#{data[key].size}"
end

append(LISTENING, "tracks", TRACKS)
append(READING, "passages", PASSAGES)
