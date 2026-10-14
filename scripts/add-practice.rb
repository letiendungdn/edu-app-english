require "json"

root = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content"

speaking = JSON.parse(File.read("#{root}/speaking.json"))
known_questions = speaking["prompts"].map { |item| item["question"] }
extra = [
  { "part" => 1, "topic" => "Food", "question" => "What do you usually eat for breakfast?", "sortOrder" => 9 },
  { "part" => 1, "topic" => "Food", "question" => "Do you prefer eating at home or in a restaurant? Why?", "sortOrder" => 10 },
  { "part" => 1, "topic" => "Music", "question" => "What kind of music do you like to listen to?", "sortOrder" => 11 },
  { "part" => 1, "topic" => "Music", "question" => "Have you ever learned to play a musical instrument?", "sortOrder" => 12 },
  { "part" => 1, "topic" => "Reading", "question" => "Do you prefer reading books or articles online?", "sortOrder" => 13 },
  { "part" => 1, "topic" => "Reading", "question" => "Did anyone read to you when you were a child?", "sortOrder" => 14 },
  { "part" => 1, "topic" => "Transport", "question" => "How do you usually travel to work or to class?", "sortOrder" => 15 },
  { "part" => 1, "topic" => "Transport", "question" => "Is traffic a problem where you live?", "sortOrder" => 16 },
  { "part" => 1, "topic" => "Daily routine", "question" => "What time do you usually get up, and why?", "sortOrder" => 17 },
  { "part" => 1, "topic" => "Daily routine", "question" => "Which part of the day do you enjoy most?", "sortOrder" => 18 },
  { "part" => 1, "topic" => "Friends", "question" => "How often do you meet your friends?", "sortOrder" => 19 },
  { "part" => 1, "topic" => "Friends", "question" => "Do you prefer a large group of friends or a few close ones?", "sortOrder" => 20 },
  {
    "part" => 2, "topic" => "A book", "sortOrder" => 4,
    "question" => "Describe a book you enjoyed reading.",
    "cueCardPoints" => ["what the book was", "when you read it", "what it was about", "and explain why you enjoyed it"]
  },
  {
    "part" => 2, "topic" => "A place in your city", "sortOrder" => 5,
    "question" => "Describe a place in your city that you like to visit.",
    "cueCardPoints" => ["where it is", "how often you go there", "what you do there", "and explain why you like it"]
  },
  {
    "part" => 2, "topic" => "A piece of technology", "sortOrder" => 6,
    "question" => "Describe a piece of technology you find useful.",
    "cueCardPoints" => ["what it is", "when you got it", "what you use it for", "and explain why it is useful to you"]
  },
  { "part" => 3, "topic" => "Books", "question" => "Why do some people prefer films to books?", "sortOrder" => 7 },
  { "part" => 3, "topic" => "Books", "question" => "Should schools spend more time on reading? Why?", "sortOrder" => 8 },
  { "part" => 3, "topic" => "Cities", "question" => "What makes a city a pleasant place to live?", "sortOrder" => 9 },
  { "part" => 3, "topic" => "Cities", "question" => "How can cities protect green spaces as they grow?", "sortOrder" => 10 },
  { "part" => 3, "topic" => "Technology", "question" => "Do people rely too much on smartphones?", "sortOrder" => 11 },
  { "part" => 3, "topic" => "Technology", "question" => "Will new technology reduce the need for some jobs?", "sortOrder" => 12 }
]
added_speaking = 0
extra.each do |item|
  next if known_questions.include?(item["question"])
  speaking["prompts"] << item
  added_speaking += 1
end
File.write("#{root}/speaking.json", JSON.pretty_generate(speaking) + "\n")

reading = JSON.parse(File.read("#{root}/reading.json"))
unless reading["passages"].any? { |item| item["title"] == "A Saturday Market" }
  reading["passages"] << {
    "title" => "A Saturday Market",
    "level" => "A2",
    "module" => "BOTH",
    "topic" => "Shopping",
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "estimatedMin" => 12,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 6,
    "content" => <<~TXT.strip,
      A
      Every Saturday, the old bus station in Riverside becomes a market. It opens at seven in the morning and closes at one. About eighty stalls stand in three rows. The first row sells fruit and vegetables. The second row sells bread, cheese and cooked food. The third row sells clothes, books and household goods. Entry is free, but the car park beside the station costs 10,000 dong an hour.

      B
      Mai has had a fruit stall there for six years. She arrives at half past five to unload boxes of oranges, mangoes and herbs. Her prices are written on a small board: oranges are 25,000 dong a kilo, and mangoes are 40,000. She keeps a tin for change under the table and does not take cards. On a busy morning she sells about thirty kilos of fruit. Her brother helps her after nine, when he finishes his shift at the bakery next door.

      C
      The market also has a notice board near the gate. This week it says that next Saturday the third row will close because the council is repairing the roof. Clothes and books will move to the school playground across the road for that one day. Cooked food will stay in the second row, but hot drinks will stop at noon instead of one. Visitors who want a table should come before eleven, because the six shared tables fill up quickly.
    TXT
    "groups" => [
      {
        "type" => "TABLE_COMPLETION",
        "instruction" => "Complete the table. Write NO MORE THAN TWO WORDS AND/OR A NUMBER for each answer.",
        "wordLimit" => 2,
        "questions" => [
          { "number" => 1, "prompt" => "Opening time: {{blank}}", "answers" => ["seven", "7"], "evidence" => "It opens at seven in the morning" },
          { "number" => 2, "prompt" => "Number of stalls: {{blank}}", "answers" => ["eighty", "80"], "evidence" => "About eighty stalls stand in three rows." },
          { "number" => 3, "prompt" => "Car park: {{blank}} dong an hour", "answers" => ["10,000", "10000"], "evidence" => "the car park beside the station costs 10,000 dong an hour." },
          { "number" => 4, "prompt" => "Mangoes: {{blank}} dong a kilo", "answers" => ["40,000", "40000"], "evidence" => "mangoes are 40,000" }
        ]
      },
      {
        "type" => "MATCHING_INFORMATION",
        "instruction" => "Which paragraph contains the following information? Write A, B or C.",
        "options" => [
          { "key" => "A", "text" => "Paragraph A" },
          { "key" => "B", "text" => "Paragraph B" },
          { "key" => "C", "text" => "Paragraph C" }
        ],
        "questions" => [
          { "number" => 5, "prompt" => "a change to the market next week", "answers" => ["C"], "evidence" => "next Saturday the third row will close" },
          { "number" => 6, "prompt" => "how one seller is paid", "answers" => ["B"], "evidence" => "does not take cards" },
          { "number" => 7, "prompt" => "what each row of the market sells", "answers" => ["A"], "evidence" => "The first row sells fruit and vegetables." }
        ]
      }
    ]
  }
end

unless reading["passages"].any? { |item| item["title"] == "The School Garden Project" }
  reading["passages"] << {
    "title" => "The School Garden Project",
    "level" => "B1",
    "module" => "ACADEMIC",
    "topic" => "Education",
    "bandMin" => 4.5,
    "bandMax" => 6.0,
    "estimatedMin" => 15,
    "source" => "EDU APP English",
    "license" => "original",
    "sortOrder" => 7,
    "content" => <<~TXT.strip,
      In 2019, Westfield Secondary School turned an unused corner of its playground into a garden. The head teacher, Helen Ward, wanted students to learn where food comes from, and she also hoped the garden would give them a reason to spend time outdoors. A local nursery donated soil, seeds and twenty wooden beds. Parents built the beds over one weekend.

      The garden now has three parts. The sunny beds grow tomatoes, beans and herbs. A shaded bed is used for lettuce. Behind them, a small shed stores tools and a rainwater tank. Students in Years 7 and 8 look after the plants on a rota: each class has the garden for one lesson a week. They record the temperature, the amount of water used, and which plants are ready to pick.

      The project has changed more than the playground. In a survey of 140 students in 2023, 68% said they had tried a vegetable at school that they had never eaten at home. Science teachers use the records in lessons on measurement and plant growth. The school kitchen takes herbs and tomatoes twice a week during term, which has cut a small part of the vegetable bill.

      There have been problems. During the long holiday the beds dried out, and in 2021 a storm broke the shed roof. The school now pays a neighbour, Mr Cole, a small fee to water the beds in July. Students also found that lettuce failed when it was planted in full sun, so they moved it. Ward says the garden is not meant to feed the whole school. Its value is that students plan, measure, fail and try again.
    TXT
    "groups" => [
      {
        "type" => "FLOW_CHART_COMPLETION",
        "instruction" => "Complete the flow chart. Write ONE WORD ONLY for each answer.",
        "wordLimit" => 1,
        "questions" => [
          { "number" => 1, "prompt" => "A nursery gave soil, seeds and wooden {{blank}}.", "answers" => ["beds"], "evidence" => "donated soil, seeds and twenty wooden beds" },
          { "number" => 2, "prompt" => "Parents built them in a {{blank}}.", "answers" => ["weekend"], "evidence" => "Parents built the beds over one weekend." },
          { "number" => 3, "prompt" => "Students write down temperature, water and plants ready to {{blank}}.", "answers" => ["pick"], "evidence" => "which plants are ready to pick" }
        ]
      },
      {
        "type" => "YES_NO_NOT_GIVEN",
        "instruction" => "Do the following statements agree with the views of the writer? Write YES, NO or NOT GIVEN.",
        "questions" => [
          { "number" => 4, "prompt" => "The garden was designed to supply every meal in the school.", "answers" => ["NO"], "evidence" => "the garden is not meant to feed the whole school" },
          { "number" => 5, "prompt" => "Most surveyed students tasted a new vegetable at school.", "answers" => ["YES"], "evidence" => "68% said they had tried a vegetable" },
          { "number" => 6, "prompt" => "Mr Cole enjoys working with the students.", "answers" => ["NOT GIVEN"], "explanation" => "Bài chỉ nói ông Cole được trả tiền để tưới cây, không nói ông có thích làm cùng học sinh hay không." }
        ]
      }
    ]
  }
end
File.write("#{root}/reading.json", JSON.pretty_generate(reading) + "\n")

listening = JSON.parse(File.read("#{root}/listening.json"))
unless listening["tracks"].any? { |item| item["title"] == "Asking for Directions" }
  listening["tracks"] << {
    "title" => "Asking for Directions",
    "level" => "A2",
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "durationSec" => 70,
    "sortOrder" => 5,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => <<~TXT.strip,
      Tourist: Excuse me, is the city museum near here?
      Local: Yes. Keep going along this street and turn left at the bookshop.
      Tourist: Left at the bookshop. Is it far?
      Local: No. It takes about ten minutes on foot. The museum is next to the post office.
      Tourist: What time does it close?
      Local: It closes at five, but the ticket office shuts at four thirty.
      Tourist: Thank you. Is there a bus?
      Local: Bus number 12 stops outside, but walking is quicker today because of the market.
    TXT
    "groups" => [
      {
        "type" => "NOTE_COMPLETION",
        "instruction" => "Complete the notes. Write ONE WORD AND/OR A NUMBER for each answer.",
        "wordLimit" => 2,
        "questions" => [
          { "number" => 1, "prompt" => "Turn left at the {{blank}}.", "answers" => ["bookshop"] },
          { "number" => 2, "prompt" => "Walking time: {{blank}} minutes.", "answers" => ["ten", "10"] },
          { "number" => 3, "prompt" => "The museum is next to the {{blank}}.", "answers" => ["post office"] },
          { "number" => 4, "prompt" => "Ticket office closes at {{blank}}.", "answers" => ["4.30", "four thirty", "4:30"] },
          { "number" => 5, "prompt" => "Bus number: {{blank}}.", "answers" => ["12"] }
        ]
      }
    ]
  }
end
File.write("#{root}/listening.json", JSON.pretty_generate(listening) + "\n")
puts "speaking_added=#{added_speaking} speaking_total=#{speaking["prompts"].size} reading=#{reading["passages"].size} listening=#{listening["tracks"].size}"
