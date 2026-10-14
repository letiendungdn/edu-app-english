# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGES = [
  {
    "title" => "Returning a library book",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "Education",
    "bandMin" => 4.0,
    "bandMax" => 5.0,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 30,
    "content" => "The city library follows the same steps for every overdue book. On the morning after the due date, the system sends an email to the member. The email names the title and asks for the book within seven days.\n\nIf the book is still out after those seven days, a fine begins. The fine is two thousand dong for each extra day. If the book has not come back after twenty-one days, the member's account is blocked. A blocked account cannot borrow again until the book is returned and the fine is paid.\n\nWhen the book arrives, a member of staff places it on the returns shelf. The next morning it goes back to its usual place in the collection.",
    "groups" => [
      {
        "type" => "FLOW_CHART_COMPLETION",
        "instruction" => "Complete the flow chart. Write ONE WORD ONLY for each answer.",
        "wordLimit" => 1,
        "questions" => [
          {
            "number" => 1,
            "prompt" => "The morning after the due date, the library sends an {{blank}}.",
            "answers" => ["email"],
            "evidence" => "the system sends an email to the member"
          },
          {
            "number" => 2,
            "prompt" => "A fine starts if the book is still out after {{blank}} days.",
            "answers" => ["seven"],
            "evidence" => "asks for the book within seven days"
          },
          {
            "number" => 3,
            "prompt" => "After twenty-one days the member's {{blank}} is blocked.",
            "answers" => ["account"],
            "evidence" => "the member's account is blocked"
          },
          {
            "number" => 4,
            "prompt" => "Staff then put the book on the returns {{blank}}.",
            "answers" => ["shelf"],
            "evidence" => "places it on the returns shelf"
          }
        ]
      }
    ]
  },
  {
    "title" => "Parts of a desk lamp",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "Home",
    "bandMin" => 4.0,
    "bandMax" => 5.0,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 31,
    "content" => "The lamp in the diagram has four parts, numbered from the top. Point 1 is the shade. It spreads the light and keeps it out of the reader's eyes. Point 2 is the bulb. This lamp uses a small LED bulb, so the shade stays cool. Point 3 is the switch, halfway down the stem. The switch has two settings, dim and bright. Point 4 is the heavy base. The base stops the lamp from tipping over when someone moves the shade.",
    "groups" => [
      {
        "type" => "DIAGRAM_LABEL",
        "instruction" => "Label the diagram. Write NO MORE THAN TWO WORDS for each answer.",
        "wordLimit" => 2,
        "imageUrl" => "/api/media/desk-lamp.svg",
        "questions" => [
          {
            "number" => 1,
            "prompt" => "1 {{blank}}",
            "answers" => ["shade"],
            "evidence" => "Point 1 is the shade."
          },
          {
            "number" => 2,
            "prompt" => "2 {{blank}}",
            "answers" => ["bulb", "LED bulb"],
            "evidence" => "Point 2 is the bulb."
          },
          {
            "number" => 3,
            "prompt" => "3 {{blank}}",
            "answers" => ["switch"],
            "evidence" => "Point 3 is the switch"
          },
          {
            "number" => 4,
            "prompt" => "4 {{blank}}",
            "answers" => ["base"],
            "evidence" => "Point 4 is the heavy base."
          }
        ]
      }
    ]
  },
  {
    "title" => "Hill Street Clinic",
    "level" => "B1",
    "module" => "GENERAL",
    "topic" => "Health",
    "bandMin" => 4.0,
    "bandMax" => 5.5,
    "estimatedMin" => 10,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 32,
    "content" => "Hill Street Clinic is on the ground floor of a small building. The map shows five places.\n\nPoint 1, just inside the north door, is reception. Patients give their name there before they sit down. Point 2, to the east of reception, is the waiting room. Magazines are on a low table, and a screen shows the ticket number. Point 3, on the south side, is the pharmacy. It closes at 5 p.m., earlier than the rest of the clinic. Point 4, in the south-west corner, is the nurse's room, where blood pressure is checked. Point 5, on the west wall, is the side exit. Patients should arrive by the north door and leave by this exit so the two queues do not meet.",
    "groups" => [
      {
        "type" => "MAP_LABELLING",
        "instruction" => "Label the map. Write NO MORE THAN TWO WORDS for each answer.",
        "wordLimit" => 2,
        "imageUrl" => "/api/media/clinic-floor.svg",
        "questions" => [
          {
            "number" => 1,
            "prompt" => "1 {{blank}}",
            "answers" => ["reception"],
            "evidence" => "Point 1, just inside the north door, is reception."
          },
          {
            "number" => 2,
            "prompt" => "2 {{blank}}",
            "answers" => ["waiting room"],
            "evidence" => "Point 2, to the east of reception, is the waiting room."
          },
          {
            "number" => 3,
            "prompt" => "3 {{blank}}",
            "answers" => ["pharmacy"],
            "evidence" => "Point 3, on the south side, is the pharmacy."
          },
          {
            "number" => 4,
            "prompt" => "4 {{blank}}",
            "answers" => ["nurse's room", "nurses room"],
            "evidence" => "Point 4, in the south-west corner, is the nurse's room"
          },
          {
            "number" => 5,
            "prompt" => "5 {{blank}}",
            "answers" => ["side exit", "exit"],
            "evidence" => "Point 5, on the west wall, is the side exit."
          }
        ]
      }
    ]
  },
  {
    "title" => "School breakfast clubs",
    "level" => "B2",
    "module" => "ACADEMIC",
    "topic" => "Education",
    "bandMin" => 5.0,
    "bandMax" => 6.5,
    "estimatedMin" => 12,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 33,
    "content" => "A\nMany primary schools now open their doors half an hour before the first lesson. The room is quiet, the lights are already on, and a small team of staff is setting out bowls. This early session is usually called a breakfast club.\n\nB\nThe clubs began for a simple reason. Teachers saw children arrive hungry, and those children found it hard to concentrate in the first lesson. A meal before school was meant to close that gap, not to replace lunch or to raise scores on a national test.\n\nC\nA typical morning is short. Pupils eat porridge or toast and a piece of fruit. Some read at a side table. Others finish homework they were too tired to do the night before. The club ends when the bell rings, and the same children go to their ordinary classes.\n\nD\nParents pay a small fee for each morning, and the school fund covers the rest. The meal is therefore cheaper than buying food on the way to school, but it is not free for every family. Staff who run the club are paid from the same fund.\n\nE\nSchools that have kept a club for a year report fewer late arrivals, and teachers say the first lesson is calmer. They do not claim that exam results have jumped. The gain they describe is a steadier start to the day.",
    "groups" => [
      {
        "type" => "MATCHING_HEADINGS",
        "instruction" => "The passage has five paragraphs, A-E. Choose the correct heading for paragraphs B-E from the list. Paragraph A is an example and is not tested.",
        "options" => [
          { "key" => "i", "text" => "Why the clubs were started" },
          { "key" => "ii", "text" => "What happens during a typical morning" },
          { "key" => "iii", "text" => "A sharp rise in exam scores" },
          { "key" => "iv", "text" => "Who pays for the meal" },
          { "key" => "v", "text" => "Changes teachers have noticed" },
          { "key" => "vi", "text" => "Why the clubs replaced lunch" },
          { "key" => "vii", "text" => "How parents cook the food at home" }
        ],
        "questions" => [
          {
            "number" => 1,
            "prompt" => "Paragraph B",
            "answers" => ["i"],
            "evidence" => "The clubs began for a simple reason. Teachers saw children arrive hungry"
          },
          {
            "number" => 2,
            "prompt" => "Paragraph C",
            "answers" => ["ii"],
            "evidence" => "A typical morning is short. Pupils eat porridge or toast"
          },
          {
            "number" => 3,
            "prompt" => "Paragraph D",
            "answers" => ["iv"],
            "evidence" => "Parents pay a small fee for each morning, and the school fund covers the rest."
          },
          {
            "number" => 4,
            "prompt" => "Paragraph E",
            "answers" => ["v"],
            "evidence" => "fewer late arrivals, and teachers say the first lesson is calmer"
          }
        ]
      }
    ]
  },
  {
    "title" => "The night bus",
    "level" => "B1",
    "module" => "GENERAL",
    "topic" => "Transport",
    "bandMin" => 4.5,
    "bandMax" => 5.5,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 34,
    "content" => "Last year the city added a night bus on route N4. It leaves the station every half hour from 11 p.m. until 5 a.m. The fare is the same as the daytime bus, and passengers can use their ordinary travel card. Drivers stop only at the marked stops, even when the bus is nearly empty. In the first three months, about 1,200 people rode the route each weekend. The council will decide in June whether to keep the service through the winter.",
    "groups" => [
      {
        "type" => "SUMMARY_COMPLETION",
        "instruction" => "Complete the summary. Write NO MORE THAN TWO WORDS from the passage for each answer.",
        "wordLimit" => 2,
        "questions" => [
          {
            "number" => 1,
            "prompt" => "The night bus runs from 11 p.m. until {{blank}}.",
            "answers" => ["5 a.m.", "5 am"],
            "evidence" => "from 11 p.m. until 5 a.m."
          },
          {
            "number" => 2,
            "prompt" => "Passengers pay the same {{blank}} as on the daytime bus.",
            "answers" => ["fare"],
            "evidence" => "The fare is the same as the daytime bus"
          },
          {
            "number" => 3,
            "prompt" => "The bus stops only at the marked {{blank}}.",
            "answers" => ["stops"],
            "evidence" => "Drivers stop only at the marked stops"
          },
          {
            "number" => 4,
            "prompt" => "The council will review the service in {{blank}}.",
            "answers" => ["June"],
            "evidence" => "The council will decide in June"
          }
        ]
      }
    ]
  }
].freeze

data = JSON.parse(File.read(PATH))
titles = data["passages"].map { |item| item["title"] }
added = 0
PASSAGES.each do |passage|
  if titles.include?(passage["title"])
    warn "skip #{passage["title"]}"
    next
  end
  data["passages"] << passage
  added += 1
end
File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "added=#{added} passages=#{data["passages"].size}"
