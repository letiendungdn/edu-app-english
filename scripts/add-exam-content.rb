require "json"

root = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content"

def add_passage(reading, passage)
  return 0 if reading["passages"].any? { |item| item["title"] == passage["title"] }
  reading["passages"] << passage
  1
end

reading = JSON.parse(File.read("#{root}/reading.json"))
added_reading = 0
added_reading += add_passage(reading, {
  "title" => "Notices in Westbrook",
  "level" => "A2",
  "module" => "GENERAL",
  "topic" => "Community",
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "estimatedMin" => 12,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 8,
  "content" => <<~TXT.strip,
    A. Library hours
    Westbrook Library is open from 9 a.m. to 7 p.m. on weekdays. On Saturday it closes at 4 p.m. It is closed on Sunday. Children under twelve must be with an adult after 5 p.m. The late fee for a book is 2,000 dong a day.

    B. Swimming pool
    The pool at Riverside Sports Centre opens at 6 a.m. and closes at 9 p.m. Adult tickets cost 40,000 dong. Students pay 25,000 dong if they show a card. The pool is closed for cleaning every Monday morning until noon.

    C. Lost property
    A blue backpack was found on bus 12 on Friday 3 March. It contains a pencil case and a library card in the name of Hoa Tran. The driver left it at the bus station office. Please collect it before 20 March and bring a photo ID.
  TXT
  "groups" => [
    {
      "type" => "MATCHING_INFORMATION",
      "instruction" => "Which notice contains the following information? Write A, B or C.",
      "options" => [
        { "key" => "A", "text" => "Library hours" },
        { "key" => "B", "text" => "Swimming pool" },
        { "key" => "C", "text" => "Lost property" }
      ],
      "questions" => [
        { "number" => 1, "prompt" => "a cheaper price for students", "answers" => ["B"], "evidence" => "Students pay 25,000 dong" },
        { "number" => 2, "prompt" => "something that must be collected by a date", "answers" => ["C"], "evidence" => "Please collect it before 20 March" },
        { "number" => 3, "prompt" => "a place that is shut one day a week", "answers" => ["A"], "evidence" => "It is closed on Sunday." }
      ]
    },
    {
      "type" => "SHORT_ANSWER",
      "instruction" => "Answer the questions. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 4, "prompt" => "What time does the library close on Saturday?", "answers" => ["4 p.m.", "4pm", "4"], "evidence" => "On Saturday it closes at 4 p.m." },
        { "number" => 5, "prompt" => "On which bus was the backpack found?", "answers" => ["12", "bus 12"], "evidence" => "found on bus 12" }
      ]
    }
  ]
})
added_reading += add_passage(reading, {
  "title" => "A job at the Riverside Hotel",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "Work",
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "estimatedMin" => 15,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 9,
  "content" => <<~TXT.strip,
    Riverside Hotel is hiring a part-time receptionist for the evening shift, from 4 p.m. to 10 p.m., five days a week. The days off are Monday and Tuesday. The pay is 35,000 dong an hour, paid every two weeks.

    The receptionist welcomes guests, gives out room keys, and answers the phone. You do not need a degree, but you must speak clear English and Vietnamese. Experience in a shop or a cafe is useful. The hotel will train you for the first week, and you will work beside Mai, the senior receptionist.

    Staff receive one free meal for each shift and a 30% discount in the hotel restaurant. Uniforms are provided. You must wear black shoes. Apply by email to jobs@riversidehotel.example before 30 April. Interviews are held on 5 May in meeting room B.
  TXT
  "groups" => [
    {
      "type" => "TABLE_COMPLETION",
      "instruction" => "Complete the table. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "Shift: 4 p.m. to {{blank}}", "answers" => ["10 p.m.", "10pm", "10"], "evidence" => "from 4 p.m. to 10 p.m." },
        { "number" => 2, "prompt" => "Days off: Monday and {{blank}}", "answers" => ["Tuesday"], "evidence" => "The days off are Monday and Tuesday." },
        { "number" => 3, "prompt" => "Pay: {{blank}} dong an hour", "answers" => ["35,000", "35000"], "evidence" => "The pay is 35,000 dong an hour" },
        { "number" => 4, "prompt" => "Meal discount: {{blank}}", "answers" => ["30%", "30"], "evidence" => "a 30% discount" }
      ]
    },
    {
      "type" => "TRUE_FALSE_NOT_GIVEN",
      "instruction" => "Do the following statements agree with the information? Write TRUE, FALSE or NOT GIVEN.",
      "questions" => [
        { "number" => 5, "prompt" => "Applicants must have a university degree.", "answers" => ["FALSE"], "evidence" => "You do not need a degree" },
        { "number" => 6, "prompt" => "The hotel gives new staff a week of training.", "answers" => ["TRUE"], "evidence" => "The hotel will train you for the first week" },
        { "number" => 7, "prompt" => "Most evening guests arrive after 8 p.m.", "answers" => ["NOT GIVEN"], "explanation" => "Bài không nói giờ khách đến." }
      ]
    }
  ]
})
added_reading += add_passage(reading, {
  "title" => "A simple home water filter",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "Home",
  "bandMin" => 4.5,
  "bandMax" => 6.0,
  "estimatedMin" => 15,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 10,
  "content" => <<~TXT.strip,
    Many homes now fit a small filter under the kitchen sink. The aim is to remove dirt and the taste of chlorine before water is used for drinking and cooking. The unit in the diagram has four parts, and water moves through them from left to right.

    Tap water first enters the unit at point 1. It is still ordinary cold water from the mains. At point 2 it meets a fine screen. The screen catches sand and rust but does not change the taste. At point 3 the water passes through a block of carbon. The carbon holds on to chlorine and some of the smells that people notice in tap water. Finally, at point 4, the cleaned water comes out of a separate drinking tap beside the sink. Water used for washing dishes does not go through the filter.

    The screen should be rinsed once a month. The carbon block lasts about six months in a family of four, and then it must be replaced. The filter does not make seawater drinkable, and it does not remove all bacteria. If the local supply is unsafe, the water should still be boiled.
  TXT
  "groups" => [
    {
      "type" => "DIAGRAM_LABEL",
      "instruction" => "Label the diagram. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/water-filter.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["tap water"], "evidence" => "Tap water first enters the unit at point 1." },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["screen", "fine screen"], "evidence" => "At point 2 it meets a fine screen." },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["carbon", "carbon block"], "evidence" => "At point 3 the water passes through a block of carbon." },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["drinking tap"], "evidence" => "at point 4, the cleaned water comes out of a separate drinking tap" }
      ]
    },
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B, C or D.",
      "questions" => [
        { "number" => 5, "prompt" => "How often should the screen be rinsed?", "answers" => ["B"], "options" => [
          { "key" => "A", "text" => "Every day" }, { "key" => "B", "text" => "Once a month" }, { "key" => "C", "text" => "Every six months" }, { "key" => "D", "text" => "Once a year" }
        ], "evidence" => "The screen should be rinsed once a month." },
        { "number" => 6, "prompt" => "What does the writer say about unsafe water?", "answers" => ["C"], "options" => [
          { "key" => "A", "text" => "The filter removes all bacteria" }, { "key" => "B", "text" => "The filter can clean seawater" }, { "key" => "C", "text" => "It should still be boiled" }, { "key" => "D", "text" => "It should not be used for cooking" }
        ], "evidence" => "If the local supply is unsafe, the water should still be boiled." }
      ]
    }
  ]
})
added_reading += add_passage(reading, {
  "title" => "Westbrook Park",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "City",
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "estimatedMin" => 12,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 11,
  "content" => <<~TXT.strip,
    Westbrook Park sits behind the library. The map shows five places.

    The main gate is at point 1, on the north side, next to the bus stop. A path leads from the gate to the lake at point 2, which is in the centre of the park. Boats are not allowed. Point 3, to the east of the lake, is the cafe. It sells drinks and sandwiches until 6 p.m. Point 4, in the south-west corner, is the children's playground. Point 5, in the south-east, is the rose garden. Dogs must stay on a lead everywhere except the playground, where they are not allowed at all. The park gates lock at 9 p.m.
  TXT
  "groups" => [
    {
      "type" => "MAP_LABELLING",
      "instruction" => "Label the map. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/park-map.svg",
      "questions" => [
        { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["main gate", "gate"], "evidence" => "The main gate is at point 1" },
        { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["lake"], "evidence" => "the lake at point 2" },
        { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["cafe"], "evidence" => "Point 3, to the east of the lake, is the cafe." },
        { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["playground"], "evidence" => "Point 4, in the south-west corner, is the children's playground." },
        { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["rose garden"], "evidence" => "Point 5, in the south-east, is the rose garden." }
      ]
    }
  ]
})
File.write("#{root}/reading.json", JSON.pretty_generate(reading) + "\n")

listening = JSON.parse(File.read("#{root}/listening.json"))
added_listening = 0
unless listening["tracks"].any? { |item| item["title"] == "Finding the sports hall" }
  listening["tracks"] << {
    "title" => "Finding the sports hall",
    "level" => "A2",
    "ieltsPart" => 2,
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "durationSec" => 70,
    "sortOrder" => 6,
    "source" => "EDU APP English",
    "license" => "original",
    "transcript" => <<~TXT.strip,
      Guide: Welcome to Riverside Sports Centre. I will point out five places on the plan.
      Guide: You are at the main entrance, which is number 1, at the bottom of the plan.
      Guide: Walk straight ahead and the swimming pool is number 2, on your left.
      Guide: Number 3, opposite the pool, is the cafe.
      Guide: The sports hall is number 4, at the far end of the corridor.
      Guide: The changing rooms are number 5, just before the sports hall, on the right.
      Guide: Please leave bags in the changing rooms. Food is only allowed in the cafe.
    TXT
    "groups" => [
      {
        "type" => "MAP_LABELLING",
        "instruction" => "Label the plan. Write NO MORE THAN TWO WORDS for each answer.",
        "wordLimit" => 2,
        "questions" => [
          { "number" => 1, "prompt" => "1 {{blank}}", "answers" => ["main entrance", "entrance"] },
          { "number" => 2, "prompt" => "2 {{blank}}", "answers" => ["swimming pool", "pool"] },
          { "number" => 3, "prompt" => "3 {{blank}}", "answers" => ["cafe"] },
          { "number" => 4, "prompt" => "4 {{blank}}", "answers" => ["sports hall"] },
          { "number" => 5, "prompt" => "5 {{blank}}", "answers" => ["changing rooms"] }
        ]
      }
    ]
  }
  added_listening = 1
end
File.write("#{root}/listening.json", JSON.pretty_generate(listening) + "\n")

speaking = JSON.parse(File.read("#{root}/speaking.json"))
known = speaking["prompts"].map { |item| item["question"] }
cards = [
  ["A cafe you like", "Describe a cafe that you like to go to.", ["where it is", "how often you go there", "what you usually order", "and explain why you like it"], 7],
  ["A teacher", "Describe a teacher who has influenced you.", ["who this teacher is", "what subject they taught", "what they did that influenced you", "and explain how you feel about them now"], 8],
  ["An important decision", "Describe an important decision you have made.", ["what the decision was", "when you made it", "what you considered", "and explain why it was important"], 9],
  ["A gift", "Describe a gift you received that was meaningful.", ["what the gift was", "who gave it to you", "when you received it", "and explain why it was meaningful"], 10],
  ["A busy day", "Describe a day when you were very busy.", ["when this day was", "what you had to do", "how you managed your time", "and explain how you felt at the end of the day"], 11],
  ["A website", "Describe a website you use often.", ["what the website is", "how you found it", "what you use it for", "and explain why you use it often"], 12]
]
added_speaking = 0
cards.each do |topic, question, points, order|
  next if known.include?(question)
  speaking["prompts"] << {
    "part" => 2, "topic" => topic, "question" => question, "cueCardPoints" => points, "sortOrder" => order
  }
  added_speaking += 1
end
File.write("#{root}/speaking.json", JSON.pretty_generate(speaking) + "\n")

tests = JSON.parse(File.read("#{root}/tests.json"))
unless tests["tests"].any? { |item| item["title"] == "Thi thử General số 1" }
  tests["tests"] << {
    "kind" => "MOCK",
    "module" => "GENERAL",
    "title" => "Thi thử General số 1",
    "description" => "Listening dùng chung với Academic, Reading là ba bài General, Writing là một thư và một bài Task 2.",
    "durationMin" => 150,
    "sortOrder" => 2,
    "sections" => [
      { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "Booking a Community Hall" },
      { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "Riverside Park Volunteer Day" },
      { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "A Research Project on Food Waste" },
      { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "The Bicycle and the City" },
      { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "Notices in Westbrook" },
      { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "A job at the Riverside Hotel" },
      { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "A simple home water filter" },
      { "skill" => "WRITING", "refType" => "WRITING_PROMPT", "title" => "Letter to a neighbour about noise" },
      { "skill" => "WRITING", "refType" => "WRITING_PROMPT", "title" => "Tourism and local culture" }
    ]
  }
end
File.write("#{root}/tests.json", JSON.pretty_generate(tests) + "\n")
puts "reading_added=#{added_reading} listening_added=#{added_listening} speaking_added=#{added_speaking} tests=#{tests["tests"].size}"
