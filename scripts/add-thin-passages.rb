# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/reading.json"

PASSAGES = [
  {
    "title" => "Sending a parcel",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "Daily life",
    "bandMin" => 4.0,
    "bandMax" => 5.0,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 35,
    "content" => "The post office on Hill Street accepts parcels until 4 p.m. First, write the address in clear letters on the front of the box. Add your own address on the back, in case the parcel cannot be delivered.\n\nAt the counter, the clerk weighs the parcel and tells you the fee. You pay in cash or by card. The clerk then gives you a receipt. Keep the receipt until the parcel arrives, because the tracking number is printed on it.",
    "groups" => [
      {
        "type" => "FLOW_CHART_COMPLETION",
        "instruction" => "Complete the flow chart. Write ONE WORD ONLY for each answer.",
        "wordLimit" => 1,
        "questions" => [
          {
            "number" => 1,
            "prompt" => "Write the {{blank}} on the front of the box.",
            "answers" => ["address"],
            "evidence" => "write the address in clear letters on the front of the box"
          },
          {
            "number" => 2,
            "prompt" => "The clerk {{blank}} the parcel.",
            "answers" => ["weighs"],
            "evidence" => "the clerk weighs the parcel"
          },
          {
            "number" => 3,
            "prompt" => "You then pay the {{blank}}.",
            "answers" => ["fee"],
            "evidence" => "tells you the fee"
          },
          {
            "number" => 4,
            "prompt" => "Keep the {{blank}} until the parcel arrives.",
            "answers" => ["receipt"],
            "evidence" => "Keep the receipt until the parcel arrives"
          }
        ]
      }
    ]
  },
  {
    "title" => "A classroom clock",
    "level" => "A2",
    "module" => "GENERAL",
    "topic" => "School",
    "bandMin" => 4.0,
    "bandMax" => 5.0,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 36,
    "content" => "The clock in the diagram hangs above the whiteboard. Point 1 is the face, a white circle with the numbers 1 to 12. Point 2 is the short hand, which shows the hour. Point 3 is the long hand, which shows the minutes. Point 4 is the battery, in a small box at the back. The caretaker changes the battery once a year, in September. Students should not open the box.",
    "groups" => [
      {
        "type" => "DIAGRAM_LABEL",
        "instruction" => "Label the diagram. Write NO MORE THAN TWO WORDS for each answer.",
        "wordLimit" => 2,
        "imageUrl" => "/api/media/classroom-clock.svg",
        "questions" => [
          {
            "number" => 1,
            "prompt" => "1 {{blank}}",
            "answers" => ["face"],
            "evidence" => "Point 1 is the face"
          },
          {
            "number" => 2,
            "prompt" => "2 {{blank}}",
            "answers" => ["short hand", "hour hand"],
            "evidence" => "Point 2 is the short hand, which shows the hour."
          },
          {
            "number" => 3,
            "prompt" => "3 {{blank}}",
            "answers" => ["long hand", "minute hand"],
            "evidence" => "Point 3 is the long hand, which shows the minutes."
          },
          {
            "number" => 4,
            "prompt" => "4 {{blank}}",
            "answers" => ["battery"],
            "evidence" => "Point 4 is the battery"
          }
        ]
      }
    ]
  },
  {
    "title" => "Street trees on Market Road",
    "level" => "B2",
    "module" => "ACADEMIC",
    "topic" => "Environment",
    "bandMin" => 5.0,
    "bandMax" => 6.5,
    "estimatedMin" => 12,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 37,
    "content" => "A\nMarket Road used to be a wide street of shops with almost no shade. In summer the pavement was too hot to stand on at noon, and several shopkeepers asked the council for trees.\n\nB\nThe council planted twenty young trees in 2021. It chose species that stay narrow, so the branches would not hide the shop signs. Each tree sits in a square of soil cut into the pavement.\n\nC\nThe first summer was difficult. Two trees died because the soil dried out, and a van broke a third when it parked on the pavement. The council replaced those three and fitted a low rail around every square.\n\nD\nShopkeepers now open their doors earlier in hot weather, and a survey in 2024 found that most customers noticed the street was cooler. The survey did not measure sales, so nobody can say the trees increased trade.\n\nE\nThe council will plant ten more trees next year, but only where the pavement is wide enough for a wheelchair to pass. It will not remove parking spaces to make room.",
    "groups" => [
      {
        "type" => "MATCHING_HEADINGS",
        "instruction" => "The passage has five paragraphs, A-E. Choose the correct heading for paragraphs B-E. Paragraph A is an example and is not tested.",
        "options" => [
          { "key" => "i", "text" => "What the council planted, and why" },
          { "key" => "ii", "text" => "Problems in the first summer" },
          { "key" => "iii", "text" => "A proven rise in shop sales" },
          { "key" => "iv", "text" => "What people noticed later" },
          { "key" => "v", "text" => "The limit on future planting" },
          { "key" => "vi", "text" => "Why the shops will close" },
          { "key" => "vii", "text" => "A plan to remove every parking space" }
        ],
        "questions" => [
          {
            "number" => 1,
            "prompt" => "Paragraph B",
            "answers" => ["i"],
            "evidence" => "The council planted twenty young trees in 2021. It chose species that stay narrow"
          },
          {
            "number" => 2,
            "prompt" => "Paragraph C",
            "answers" => ["ii"],
            "evidence" => "The first summer was difficult. Two trees died"
          },
          {
            "number" => 3,
            "prompt" => "Paragraph D",
            "answers" => ["iv"],
            "evidence" => "most customers noticed the street was cooler"
          },
          {
            "number" => 4,
            "prompt" => "Paragraph E",
            "answers" => ["v"],
            "evidence" => "only where the pavement is wide enough"
          }
        ]
      }
    ]
  },
  {
    "title" => "The weekend ferry",
    "level" => "B1",
    "module" => "GENERAL",
    "topic" => "Transport",
    "bandMin" => 4.5,
    "bandMax" => 5.5,
    "estimatedMin" => 8,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 38,
    "content" => "A small ferry now runs from the town quay to Pine Island on Saturdays and Sundays. The first boat leaves at 9 a.m. and the last returns at 6 p.m. A return ticket costs 40,000 dong, and children under five travel free. Bicycles are allowed, but cars are not. The crossing takes about twenty minutes if the water is calm. In June the council will decide whether to add a Friday boat.",
    "groups" => [
      {
        "type" => "SUMMARY_COMPLETION",
        "instruction" => "Complete the summary. Write NO MORE THAN TWO WORDS AND/OR A NUMBER from the passage for each answer.",
        "wordLimit" => 2,
        "questions" => [
          {
            "number" => 1,
            "prompt" => "The first boat leaves at {{blank}}.",
            "answers" => ["9 a.m.", "9 am"],
            "evidence" => "The first boat leaves at 9 a.m."
          },
          {
            "number" => 2,
            "prompt" => "A return ticket costs {{blank}} dong.",
            "answers" => ["40,000", "40000"],
            "evidence" => "A return ticket costs 40,000 dong"
          },
          {
            "number" => 3,
            "prompt" => "Passengers may take {{blank}}, but not cars.",
            "answers" => ["bicycles"],
            "evidence" => "Bicycles are allowed, but cars are not."
          },
          {
            "number" => 4,
            "prompt" => "The council will review a Friday boat in {{blank}}.",
            "answers" => ["June"],
            "evidence" => "In June the council will decide"
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
