require "json"

root = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content"

def words(text)
  text.to_s.scan(/[A-Za-z0-9''-]+/).size
end

def add_unique(list, item, key)
  return 0 if list.any? { |row| row[key] == item[key] }
  list << item
  1
end

reading = JSON.parse(File.read("#{root}/reading.json"))
listening = JSON.parse(File.read("#{root}/listening.json"))
writing = JSON.parse(File.read("#{root}/writing.json"))
tests = JSON.parse(File.read("#{root}/tests.json"))
added = { "reading" => 0, "listening" => 0, "writing" => 0, "tests" => 0 }

added["reading"] += add_unique(reading["passages"], {
  "title" => "Notices at Greenfield Centre",
  "level" => "A2",
  "module" => "GENERAL",
  "topic" => "Community",
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "estimatedMin" => 12,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 30,
  "content" => <<~TXT.strip,
    A. Yoga class
    The Tuesday yoga class meets at 7 p.m. in room 4. A single class costs 80,000 dong. Please bring your own mat. The first class for new members is free. Call Mai on 0904 220 118 if you want a place.

    B. Lost keys
    A silver key ring was found in the centre cafe on Saturday 4 May. It has three keys and a small red label. The cafe manager left it at reception. Please collect it before 18 May and bring a photo ID.

    C. Book sale
    The Saturday book sale runs from 10 a.m. to 2 p.m. in the hall. Paperbacks cost 20,000 dong. Children's books are half price. Payment is in cash only. Unsold books will be given to the school library.
  TXT
  "groups" => [
    {
      "type" => "MATCHING_INFORMATION",
      "instruction" => "Which notice contains the following information? Write A, B or C.",
      "options" => [
        { "key" => "A", "text" => "Yoga class" },
        { "key" => "B", "text" => "Lost keys" },
        { "key" => "C", "text" => "Book sale" }
      ],
      "questions" => [
        { "number" => 1, "prompt" => "something that must be collected by a date", "answers" => ["B"], "evidence" => "Please collect it before 18 May" },
        { "number" => 2, "prompt" => "a lower price for children's books", "answers" => ["C"], "evidence" => "Children's books are half price." },
        { "number" => 3, "prompt" => "a class that is free the first time", "answers" => ["A"], "evidence" => "The first class for new members is free." }
      ]
    },
    {
      "type" => "SHORT_ANSWER",
      "instruction" => "Answer the questions. Write NO MORE THAN THREE WORDS AND/OR A NUMBER.",
      "wordLimit" => 3,
      "questions" => [
        { "number" => 4, "prompt" => "What should yoga students bring?", "answers" => ["a mat", "mat", "their own mat"], "evidence" => "Please bring your own mat." },
        { "number" => 5, "prompt" => "How can people pay at the book sale?", "answers" => ["cash", "in cash"], "evidence" => "Payment is in cash only." }
      ]
    }
  ]
}, "title")

added["reading"] += add_unique(reading["passages"], {
  "title" => "A room in a shared flat",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "Home",
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "estimatedMin" => 15,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 31,
  "content" => <<~TXT.strip,
    A furnished room is available in a shared flat on Nguyen Trai Street, five minutes from the bus stop. The rent is 3,200,000 dong a month, including water. Electricity is shared by the three people who live there and is usually about 200,000 dong each.

    The room has a bed, a desk and a wardrobe. The kitchen and bathroom are shared. Smoking is not allowed in the flat. Guests may stay one night if the other flatmates agree the day before.

    The current flatmates are a nurse who works nights and a student who is usually at the library in the afternoon. They would like someone quiet, with a steady job or a place on a course. A one-month deposit is required. The room is free from 1 June. Viewings are on Saturday at 10 a.m. Email hoa.flat@example.com.
  TXT
  "groups" => [
    {
      "type" => "TABLE_COMPLETION",
      "instruction" => "Complete the table. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "Rent: {{blank}} dong a month", "answers" => ["3,200,000", "3200000"] },
        { "number" => 2, "prompt" => "Included in the rent: {{blank}}", "answers" => ["water"] },
        { "number" => 3, "prompt" => "Usual electricity for each person: {{blank}} dong", "answers" => ["200,000", "200000"] },
        { "number" => 4, "prompt" => "Deposit: {{blank}} month", "answers" => ["one", "1"] },
        { "number" => 5, "prompt" => "Available from: 1 {{blank}}", "answers" => ["June"] }
      ]
    },
    {
      "type" => "TRUE_FALSE_NOT_GIVEN",
      "instruction" => "Do the following statements agree with the information? Write TRUE, FALSE or NOT GIVEN.",
      "questions" => [
        { "number" => 6, "prompt" => "The flat is a long way from public transport.", "answers" => ["FALSE"], "evidence" => "five minutes from the bus stop" },
        { "number" => 7, "prompt" => "Smoking is allowed on the balcony.", "answers" => ["NOT GIVEN"], "evidence" => "The notice only says smoking is not allowed in the flat." },
        { "number" => 8, "prompt" => "Viewings take place on Saturday morning.", "answers" => ["TRUE"], "evidence" => "Viewings are on Saturday at 10 a.m." }
      ]
    }
  ]
}, "title")

added["reading"] += add_unique(reading["passages"], {
  "title" => "Using the library printers",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "Education",
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "estimatedMin" => 12,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 32,
  "content" => <<~TXT.strip,
    Westbrook Library has two printers next to the information desk. To print, you need a library card with money on it. Add credit at the desk. The minimum is 10,000 dong. Black-and-white pages cost 500 dong. Colour pages cost 2,000 dong.

    Send the file from the library computers, or from your phone using the network called Library-Print. The password is printed on the card beside the printers. Collect your pages within one hour. After that, the job is deleted and the money is not returned.

    Staff can help you the first time. They cannot print copyrighted books in full. You may print up to 30 pages of a book for study. The printers are switched off 15 minutes before the library closes.
  TXT
  "groups" => [
    {
      "type" => "SHORT_ANSWER",
      "instruction" => "Answer the questions. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "Where do you add credit?", "answers" => ["the desk", "information desk", "at the desk"], "evidence" => "Add credit at the desk." },
        { "number" => 2, "prompt" => "How much is a colour page?", "answers" => ["2,000 dong", "2000", "2,000"], "evidence" => "Colour pages cost 2,000 dong." },
        { "number" => 3, "prompt" => "How long do you have to collect a print job?", "answers" => ["one hour", "1 hour"], "evidence" => "Collect your pages within one hour." }
      ]
    },
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B, C or D.",
      "questions" => [
        {
          "number" => 4,
          "prompt" => "What can staff not do?",
          "answers" => ["B"],
          "options" => [
            { "key" => "A", "text" => "Help a person the first time" },
            { "key" => "B", "text" => "Print a whole copyrighted book" },
            { "key" => "C", "text" => "Tell people the network name" },
            { "key" => "D", "text" => "Add credit to a card" }
          ]
        },
        {
          "number" => 5,
          "prompt" => "When are the printers switched off?",
          "answers" => ["C"],
          "options" => [
            { "key" => "A", "text" => "One hour after a job is sent" },
            { "key" => "B", "text" => "At the information desk" },
            { "key" => "C", "text" => "15 minutes before closing" },
            { "key" => "D", "text" => "When a card has 10,000 dong" }
          ]
        }
      ]
    }
  ]
}, "title")

lost_bag = <<~TXT.strip
  Clerk: Good afternoon, station office. How can I help you?
  Caller: Hello. I think I left my bag on the 3.15 train from Eastvale.
  Clerk: Can I take your name?
  Caller: Helen Brooks. That's B-R-O-O-K-S.
  Clerk: Thank you. What does the bag look like?
  Caller: It is a blue backpack. There is a grey wallet inside and a library card.
  Clerk: Where did you get off?
  Caller: At Central Station, on platform 2.
  Clerk: We have a blue backpack from that train. You can collect it tomorrow after 9 a.m. Please bring photo ID. There is a fee of 5 pounds.
TXT

added["listening"] += add_unique(listening["tracks"], {
  "title" => "A bag left on the train",
  "level" => "B1",
  "ieltsPart" => 1,
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "durationSec" => 90,
  "sortOrder" => 30,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => lost_bag,
  "groups" => [
    {
      "type" => "FORM_COMPLETION",
      "instruction" => "Complete the form. Write ONE WORD AND/OR A NUMBER for each answer.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "Train time: {{blank}}", "answers" => ["3.15", "3:15"] },
        { "number" => 2, "prompt" => "Train from: {{blank}}", "answers" => ["Eastvale"] },
        { "number" => 3, "prompt" => "Surname: {{blank}}", "answers" => ["Brooks"] },
        { "number" => 4, "prompt" => "Bag colour: {{blank}}", "answers" => ["blue"] },
        { "number" => 5, "prompt" => "Got off at platform: {{blank}}", "answers" => ["2", "two"] },
        { "number" => 6, "prompt" => "Collect after: {{blank}} a.m.", "answers" => ["9", "nine"] },
        { "number" => 7, "prompt" => "Fee: £{{blank}}", "answers" => ["5", "five"] }
      ]
    }
  ]
}, "title")

tour = <<~TXT.strip
  Guide: Welcome to the Sunday walking tour. We meet at the clock tower at 9.30. The tour lasts about 90 minutes and costs 12 pounds. Children under 12 are free.
  We start in the old market, then walk along River Street to the stone bridge. Please stay on the pavement, because the road is busy on Sundays.
  At 10.15 we stop at the bakery for ten minutes. You can buy a drink, but the tour does not include food.
  If it rains, we still go ahead, so bring a light jacket. The tour ends at the museum gate. Toilets are inside the museum, and you do not need a ticket to use them. The guide's name is Marco.
TXT

added["listening"] += add_unique(listening["tracks"], {
  "title" => "Sunday walking tour",
  "level" => "B2",
  "ieltsPart" => 2,
  "bandMin" => 5.0,
  "bandMax" => 6.5,
  "durationSec" => 110,
  "sortOrder" => 31,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => tour,
  "groups" => [
    {
      "type" => "NOTE_COMPLETION",
      "instruction" => "Complete the notes. Write ONE WORD AND/OR A NUMBER for each answer.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "Meet at the clock {{blank}}", "answers" => ["tower"] },
        { "number" => 2, "prompt" => "Meeting time: {{blank}}", "answers" => ["9.30", "9:30"] },
        { "number" => 3, "prompt" => "Adult price: £{{blank}}", "answers" => ["12", "twelve"] },
        { "number" => 4, "prompt" => "Children under {{blank}} are free", "answers" => ["12", "twelve"] },
        { "number" => 5, "prompt" => "Bakery stop at {{blank}}", "answers" => ["10.15", "10:15"] },
        { "number" => 6, "prompt" => "Bring a light {{blank}} if it rains", "answers" => ["jacket"] },
        { "number" => 7, "prompt" => "Tour ends at the museum {{blank}}", "answers" => ["gate"] },
        { "number" => 8, "prompt" => "Guide's name: {{blank}}", "answers" => ["Marco"] }
      ]
    }
  ]
}, "title")

class_talk = <<~TXT.strip
  Tutor: You both want an evening class. Have you chosen one?
  Nina: I like the photography class on Wednesday. It starts at 6.30 and runs for eight weeks. The camera is provided.
  Sam: Wednesday is my late shift. The cooking class is on Thursday, and it costs 90 pounds, which is less than photography.
  Nina: Cooking finishes at 9, and the last bus on my route is at 8.45. I would have to take a taxi.
  Tutor: There is also a writing class on Tuesday. It is free for library members, and it ends at 8. You only need a notebook.
  Sam: Tuesday works for me. Nina, if the bus is the problem, Tuesday is safer than Thursday.
  Nina: All right. Let's take the writing class. I already have a library card.
TXT

added["listening"] += add_unique(listening["tracks"], {
  "title" => "Choosing an evening class",
  "level" => "B2",
  "ieltsPart" => 3,
  "bandMin" => 5.0,
  "bandMax" => 6.5,
  "durationSec" => 100,
  "sortOrder" => 32,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => class_talk,
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B or C.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "Why does Nina like the photography class?",
          "answers" => ["B"],
          "options" => [
            { "key" => "A", "text" => "It is the cheapest class" },
            { "key" => "B", "text" => "A camera is provided" },
            { "key" => "C", "text" => "It ends before 8" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Why can Sam not go on Wednesday?",
          "answers" => ["A"],
          "options" => [
            { "key" => "A", "text" => "He works a late shift" },
            { "key" => "B", "text" => "The class is full" },
            { "key" => "C", "text" => "He has no camera" }
          ]
        },
        {
          "number" => 3,
          "prompt" => "What problem does Nina have with the cooking class?",
          "answers" => ["C"],
          "options" => [
            { "key" => "A", "text" => "It costs more than photography" },
            { "key" => "B", "text" => "It is on Tuesday" },
            { "key" => "C", "text" => "She would miss the last bus" }
          ]
        },
        {
          "number" => 4,
          "prompt" => "Which class do they choose?",
          "answers" => ["B"],
          "options" => [
            { "key" => "A", "text" => "Photography" },
            { "key" => "B", "text" => "Writing" },
            { "key" => "C", "text" => "Cooking" }
          ]
        },
        {
          "number" => 5,
          "prompt" => "What does Nina already have?",
          "answers" => ["A"],
          "options" => [
            { "key" => "A", "text" => "A library card" },
            { "key" => "B", "text" => "A camera" },
            { "key" => "C", "text" => "A notebook" }
          ]
        }
      ]
    }
  ]
}, "title")

garden = <<~TXT.strip
  Speaker: The community garden behind the health centre opened in March. Twenty families share sixteen beds. Each family pays 15 pounds a year, which covers seeds and tools. Water comes from a tank on the roof, so we ask people not to leave hoses running.
  Work sessions are on Saturday morning, from 8 to 11. If you cannot come, tell the coordinator, Priya, by Friday. Tools stay in the green shed. The code for the lock is on your membership card. Please lock the shed even if you think someone else is still inside.
  We grow vegetables, not flowers. In the first season the most successful crops were beans and lettuce. Tomatoes needed more sun than this site gets. Produce is shared among the families who worked that month. Nothing is sold. Visitors are welcome on the first Sunday of the month, but they should stay on the path.
TXT

added["listening"] += add_unique(listening["tracks"], {
  "title" => "The community garden",
  "level" => "B2",
  "ieltsPart" => 4,
  "bandMin" => 5.0,
  "bandMax" => 6.5,
  "durationSec" => 120,
  "sortOrder" => 33,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => garden,
  "groups" => [
    {
      "type" => "NOTE_COMPLETION",
      "instruction" => "Complete the notes. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "The garden opened in {{blank}}", "answers" => ["March"] },
        { "number" => 2, "prompt" => "Number of beds: {{blank}}", "answers" => ["16", "sixteen"] },
        { "number" => 3, "prompt" => "Yearly fee: £{{blank}}", "answers" => ["15", "fifteen"] },
        { "number" => 4, "prompt" => "Water comes from a {{blank}}", "answers" => ["tank"] },
        { "number" => 5, "prompt" => "Tell Priya by {{blank}} if you cannot come", "answers" => ["Friday"] },
        { "number" => 6, "prompt" => "Tools are kept in the green {{blank}}", "answers" => ["shed"] },
        { "number" => 7, "prompt" => "Crops that did well: beans and {{blank}}", "answers" => ["lettuce"] },
        { "number" => 8, "prompt" => "Visitors should stay on the {{blank}}", "answers" => ["path"] }
      ]
    }
  ]
}, "title")

heater = <<~TXT.strip
  Dear Mr Cole,

  I am writing about the heater in my flat at 14 River Street. It stopped working on Monday evening, and the bedroom has been very cold since then. I have a young son who has had a cough this week, and it is difficult for him to sleep in that room.

  Could you send someone to look at the heater this week? I am at home after 5.30 p.m. on weekdays, and I can also be there on Saturday morning. If the heater cannot be repaired quickly, a small electric heater for a few days would help.

  Please call me on 0912 448 330 or reply to this letter. I would like the problem fixed before the weekend if possible. I can meet the repair person at the flat, and I will move the furniture away from the heater so the work can be done quickly. Thank you for your help with this.

  Yours sincerely,
  Mai Tran
TXT
raise "heater #{words(heater)}" if words(heater) < 150

added["writing"] += add_unique(writing["prompts"], {
  "module" => "GENERAL",
  "task" => "TASK1",
  "taskKind" => "LETTER",
  "sortOrder" => 30,
  "title" => "Letter about a broken heater",
  "topic" => "Home",
  "minWords" => 150,
  "prompt" => "The heater in your rented flat has stopped working.\n\nWrite a letter to your landlord. In your letter\n- describe the problem\n- explain how it is affecting you\n- say what you would like the landlord to do\n\nBegin your letter as follows: Dear ...,",
  "sampleAnswer" => heater,
  "sampleBand" => 6.5
}, "title")

food = <<~TXT.strip
  Some people believe that families in cities should grow at least some of their own food. I agree that a small amount of home growing is useful, but it cannot replace farms, and it only works when people have time, space and clean soil.

  Growing a few herbs or salad leaves has clear benefits. The food is fresh, and children learn where a tomato comes from. A balcony box also uses a little water and almost no packaging. For a household that buys herbs in plastic every week, this is a real saving. There is a social benefit too. Shared gardens give neighbours a reason to cooperate, and the community garden near our health centre already shows that twenty families can share a small piece of land.

  The limits are just as important. A flat without a balcony cannot produce rice, meat or cooking oil. Soil in some city yards is poor or polluted, so vegetables grown there may not be safe. Time is another barrier. A nurse on night shifts cannot look after plants every day, and a failed crop is not a lesson if the family needed that food.

  Cities should therefore make growing easy rather than compulsory. Roof beds, safe soil tests and short evening classes would help people who want to try. Households without space should not be blamed for buying food. In short, growing a little of what you eat is a good habit. Treating it as a duty for every city family ignores how people actually live.
TXT
raise "food #{words(food)}" if words(food) < 250

added["writing"] += add_unique(writing["prompts"], {
  "module" => "BOTH",
  "task" => "TASK2",
  "taskKind" => "OPINION",
  "sortOrder" => 31,
  "title" => "Growing food in the city",
  "topic" => "Environment",
  "minWords" => 250,
  "prompt" => "Some people think that everyone who lives in a city should grow some of their own food. To what extent do you agree or disagree?",
  "sampleAnswer" => food,
  "sampleBand" => 6.5
}, "title")

added["tests"] += add_unique(tests["tests"], {
  "kind" => "MOCK",
  "module" => "GENERAL",
  "title" => "Thi thử General số 2",
  "description" => "Đề General thứ hai, không dùng lại bài của đề General số 1: Listening 4 phần mới, Reading 3 bài mới, một thư và một bài Task 2 mới. Speaking luyện riêng ở mục Speaking.",
  "durationMin" => 150,
  "sortOrder" => 4,
  "sections" => [
    { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "A bag left on the train" },
    { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "Sunday walking tour" },
    { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "Choosing an evening class" },
    { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "The community garden" },
    { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "Notices at Greenfield Centre" },
    { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "A room in a shared flat" },
    { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "Using the library printers" },
    { "skill" => "WRITING", "refType" => "WRITING_PROMPT", "title" => "Letter about a broken heater" },
    { "skill" => "WRITING", "refType" => "WRITING_PROMPT", "title" => "Growing food in the city" }
  ]
}, "title")

File.write("#{root}/reading.json", JSON.pretty_generate(reading) + "\n")
File.write("#{root}/listening.json", JSON.pretty_generate(listening) + "\n")
File.write("#{root}/writing.json", JSON.pretty_generate(writing) + "\n")
File.write("#{root}/tests.json", JSON.pretty_generate(tests) + "\n")
puts added.map { |k, v| "#{k}=#{v}" }.join(" ")
puts "heater_words=#{words(heater)} food_words=#{words(food)}"
