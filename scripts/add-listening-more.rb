# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/listening.json"

TRACKS = [
  {
    "title" => "A bike for the weekend",
    "level" => "A2",
    "ieltsPart" => 1,
    "bandMin" => 3.5,
    "bandMax" => 5.0,
    "durationSec" => 50,
    "sortOrder" => 43,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Staff: Green Wheel hire, good morning.\nLinh: Hello. I would like a bike for Sunday.\nStaff: What name should I put on the form?\nLinh: Linh Pham.\nStaff: A city bike or a mountain bike?\nLinh: A city bike, please.\nStaff: For how many hours?\nLinh: Three hours.\nStaff: That is twelve pounds, and we need the bike back by five. Helmets are free. Please bring your student card.",
    "groups" => [
      {
        "type" => "FORM_COMPLETION",
        "instruction" => "Complete the form. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
        "wordLimit" => 2,
        "questions" => [
          { "number" => 1, "prompt" => "Day: {{blank}}", "answers" => ["Sunday"], "evidence" => "a bike for Sunday" },
          { "number" => 2, "prompt" => "Name: {{blank}}", "answers" => ["Linh Pham"], "evidence" => "Linh Pham" },
          { "number" => 3, "prompt" => "Type of bike: {{blank}}", "answers" => ["city", "city bike"], "evidence" => "A city bike, please." },
          { "number" => 4, "prompt" => "Number of hours: {{blank}}", "answers" => ["3", "three"], "evidence" => "Three hours." },
          { "number" => 5, "prompt" => "Price: {{blank}} pounds", "answers" => ["12", "twelve"], "evidence" => "twelve pounds" }
        ]
      }
    ]
  },
  {
    "title" => "Choosing a presentation topic",
    "level" => "B1",
    "ieltsPart" => 3,
    "bandMin" => 4.5,
    "bandMax" => 6.0,
    "durationSec" => 70,
    "sortOrder" => 44,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Mai: We still need a topic for Friday's presentation. I wanted to talk about city bikes, but the tutor said another group has taken transport.\nKhoa: What about the library's new late hours? They stay open until ten on weekdays now.\nMai: That is useful, but it is only a short announcement. We need something we can explain for eight minutes.\nKhoa: Then let's do food waste in the student canteen. I interviewed the manager yesterday, and she said most waste is bread and salad, not meat.\nMai: Perfect. I will make the slides, and you can present the interview. We should bring one chart and finish with three tips.\nKhoa: Agreed. Let's meet at the library at four to practise once.",
    "groups" => [
      {
        "type" => "MULTIPLE_CHOICE",
        "instruction" => "Choose the correct letter, A, B or C.",
        "questions" => [
          {
            "number" => 1,
            "prompt" => "Why do they reject the topic of city bikes?",
            "answers" => ["B"],
            "evidence" => "another group has taken transport",
            "options" => [
              { "key" => "A", "text" => "The tutor dislikes bikes." },
              { "key" => "B", "text" => "Another group is already doing transport." },
              { "key" => "C", "text" => "They cannot find any pictures." }
            ]
          },
          {
            "number" => 2,
            "prompt" => "What is the problem with the library topic?",
            "answers" => ["A"],
            "evidence" => "it is only a short announcement",
            "options" => [
              { "key" => "A", "text" => "There is not enough to say." },
              { "key" => "B", "text" => "The library closes at six." },
              { "key" => "C", "text" => "Students may not visit the library." }
            ]
          },
          {
            "number" => 3,
            "prompt" => "Most canteen waste is",
            "answers" => ["C"],
            "evidence" => "most waste is bread and salad, not meat",
            "options" => [
              { "key" => "A", "text" => "meat." },
              { "key" => "B", "text" => "rice." },
              { "key" => "C", "text" => "bread and salad." }
            ]
          },
          {
            "number" => 4,
            "prompt" => "Who will present the interview?",
            "answers" => ["B"],
            "evidence" => "you can present the interview",
            "options" => [
              { "key" => "A", "text" => "Mai" },
              { "key" => "B", "text" => "Khoa" },
              { "key" => "C", "text" => "The canteen manager" }
            ]
          },
          {
            "number" => 5,
            "prompt" => "When will they practise?",
            "answers" => ["A"],
            "evidence" => "meet at the library at four",
            "options" => [
              { "key" => "A", "text" => "At four in the library" },
              { "key" => "B", "text" => "At ten in the canteen" },
              { "key" => "C", "text" => "On Friday morning" }
            ]
          }
        ]
      }
    ]
  },
  {
    "title" => "How bees find flowers",
    "level" => "B2",
    "ieltsPart" => 4,
    "bandMin" => 5.0,
    "bandMax" => 6.5,
    "durationSec" => 80,
    "sortOrder" => 45,
    "source" => "EDU APP English (giọng đọc máy)",
    "license" => "original",
    "transcript" => "Lecturer: A honeybee that finds a rich patch of flowers has to tell the rest of the hive. She does this with a dance on the comb, in the dark, so the other bees follow the movement rather than a picture.\nIf the flowers are close, within about fifty metres, she turns in tight circles. This round dance says the patch is near, but it does not give a direction. For anything farther, she uses a waggle dance. The angle of the straight run, compared with the top of the comb, matches the angle between the sun and the flowers. The length of the waggle tells the distance. A longer waggle means a longer flight.\nThe dance is surprisingly accurate, yet it is not a map. Wind, hills, and a cloudy sky all make the route harder, and bees still search when they arrive in the area. The dance gets them to the right neighbourhood. Their eyes and their sense of smell finish the job.",
    "groups" => [
      {
        "type" => "NOTE_COMPLETION",
        "instruction" => "Complete the notes. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
        "wordLimit" => 2,
        "questions" => [
          { "number" => 1, "prompt" => "The dance happens in the {{blank}}.", "answers" => ["dark"], "evidence" => "in the dark" },
          { "number" => 2, "prompt" => "A round dance is used within about {{blank}} metres.", "answers" => ["50", "fifty"], "evidence" => "within about fifty metres" },
          { "number" => 3, "prompt" => "The round dance does not give a {{blank}}.", "answers" => ["direction"], "evidence" => "it does not give a direction" },
          { "number" => 4, "prompt" => "The waggle is compared with the top of the {{blank}}.", "answers" => ["comb"], "evidence" => "compared with the top of the comb" },
          { "number" => 5, "prompt" => "A longer waggle means a longer {{blank}}.", "answers" => ["flight"], "evidence" => "A longer waggle means a longer flight." }
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
