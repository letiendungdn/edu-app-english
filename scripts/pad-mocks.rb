# frozen_string_literal: true

require "json"

ROOT = "backend/src/main/resources/content"

def load(name)
  JSON.parse(File.read("#{ROOT}/#{name}"))
end

def save(name, data)
  File.write("#{ROOT}/#{name}", JSON.pretty_generate(data) + "\n")
end

def find_item(list, title)
  item = list.find { |row| row["title"] == title }
  raise "missing #{title}" unless item
  item
end

def next_number(item)
  nums = item["groups"].flat_map { |group| group["questions"].map { |q| q["number"].to_i } }
  (nums.max || 0) + 1
end

def add_group(item, group)
  known = item["groups"].flat_map { |g| g["questions"].map { |q| q["prompt"] } }
  group["questions"].each do |q|
    raise "duplicate prompt: #{q["prompt"]}" if known.include?(q["prompt"])
  end
  item["groups"] << group
end

def choice(key, text)
  { "key" => key, "text" => text }
end

def mc(number, prompt, answer, options, evidence = nil)
  row = { "number" => number, "prompt" => prompt, "answers" => [answer], "options" => options }
  row["evidence"] = evidence if evidence
  row
end

def typed(number, prompt, answers, evidence = nil)
  row = { "number" => number, "prompt" => prompt, "answers" => answers }
  row["evidence"] = evidence if evidence
  row
end

def judged(number, prompt, answer, evidence)
  { "number" => number, "prompt" => prompt, "answers" => [answer], "evidence" => evidence }
end

reading = load("reading.json")
listening = load("listening.json")
tests = load("tests.json")

repair = find_item(reading["passages"], "Repair cafes and the right to fix")
n = next_number(repair)
add_group(repair, {
  "type" => "MATCHING_SENTENCE_ENDINGS",
  "instruction" => "Complete each sentence with the correct ending, A-G.",
  "options" => [
    choice("A", "opened in Amsterdam in 2009."),
    choice("B", "are not charged for the labour."),
    choice("C", "does not cancel the impact of larger purchases such as cars."),
    choice("D", "ignores how long software updates will last."),
    choice("E", "was started by the Bristol volunteers."),
    choice("F", "sells spare parts at a profit."),
    choice("G", "covers cars and heating systems.")
  ],
  "questions" => [
    judged(n, "The first repair cafe", "A", "The first repair cafe opened in Amsterdam in 2009."),
    judged(n + 1, "Most visitors", "B", "Visitors pay nothing for the labour"),
    judged(n + 2, "A repaired kettle", "C", "It does not, however, cancel the impact of the much larger things people buy, such as cars"),
    judged(n + 3, "Critics say the French repair score", "D", "it ignores how long software updates will last")
  ]
})

forests = find_item(reading["passages"], "Tiny forests in crowded cities")
n = next_number(forests)
add_group(forests, {
  "type" => "FLOW_CHART_COMPLETION",
  "instruction" => "Complete the flow chart. Write ONE WORD ONLY from the passage.",
  "wordLimit" => 1,
  "questions" => [
    typed(n, "Teachers use the plots for {{blank}} lessons.", ["biology"], "Teachers use the plots for biology lessons."),
    typed(n + 1, "Residents say the sites are {{blank}} in summer than the pavement.", ["cooler"], "the sites are cooler in summer"),
    typed(n + 2, "The honest local case includes shade and {{blank}}.", ["habitat"], "The honest case is local: shade, habitat")
  ]
})

nights = find_item(reading["passages"], "The cost of working at night")
n = next_number(nights)
add_group(nights, {
  "type" => "MULTIPLE_CHOICE_MULTI",
  "instruction" => "Choose TWO letters, A-E. Which TWO actions does Berg recommend?",
  "questions" => [
    {
      "number" => n,
      "prompt" => "Which TWO actions does Berg recommend?",
      "answers" => ["A", "C"],
      "evidence" => "capping long runs of nights, publishing rotas at least two weeks ahead",
      "options" => [
        choice("A", "Cap long runs of night shifts"),
        choice("B", "Ban every night shift"),
        choice("C", "Publish rotas at least two weeks ahead"),
        choice("D", "Close wards that lack nurses"),
        choice("E", "Move all heavy tasks to the morning")
      ]
    }
  ]
})
add_group(nights, {
  "type" => "SHORT_ANSWER",
  "instruction" => "Answer the questions. Write ONE WORD ONLY from the passage.",
  "wordLimit" => 1,
  "questions" => [
    typed(n + 1, "Night workers often sleep in short {{blank}}.", ["blocks"], "sleep in short blocks"),
    typed(n + 2, "A useful nap lasts about twenty {{blank}}.", ["minutes"], "Short naps of about twenty minutes")
  ]
})

bees = find_item(reading["passages"], "The Return of the Urban Beekeeper")
n = next_number(bees)
add_group(bees, {
  "type" => "TRUE_FALSE_NOT_GIVEN",
  "instruction" => "Do the following statements agree with the information in the passage? Write TRUE, FALSE or NOT GIVEN.",
  "questions" => [
    judged(n, "The passage mentions hives at railway stations in Tokyo.", "TRUE", "railway stations in Tokyo")
  ]
})

waste = find_item(listening["tracks"], "A Research Project on Food Waste")
n = next_number(waste)
add_group(waste, {
  "type" => "MULTIPLE_CHOICE",
  "instruction" => "Choose the correct letter, A, B or C.",
  "questions" => [
    mc(n, "Where did the students collect their data?", "B", [
      choice("A", "In restaurants"),
      choice("B", "In student halls"),
      choice("C", "In a supermarket")
    ], "focus on student halls rather than restaurants")
  ]
})

dental = find_item(listening["tracks"], "A check-up at City Dental")
n = next_number(dental)
add_group(dental, {
  "type" => "FORM_COMPLETION",
  "instruction" => "Complete the notes. Write ONE WORD AND/OR A NUMBER.",
  "wordLimit" => 2,
  "questions" => [
    typed(n, "Bring a photo {{blank}}", ["ID"], "bring a photo ID"),
    typed(n + 1, "The clinic car park is full by {{blank}}", ["9", "nine"], "The clinic car park is full by nine")
  ]
})

market = find_item(listening["tracks"], "Friday night market")
n = next_number(market)
add_group(market, {
  "type" => "NOTE_COMPLETION",
  "instruction" => "Complete the notes. Write ONE WORD ONLY.",
  "wordLimit" => 1,
  "questions" => [
    typed(n, "The soup stall has {{blank}}", ["seats"], "the soup stall at the far end has seats"),
    typed(n + 1, "Leave bicycles at the green {{blank}}", ["rack"], "the green rack beside the station entrance"),
    typed(n + 2, "Toilets are behind the clock {{blank}}", ["tower"], "Toilets are behind the clock tower")
  ]
})

method = find_item(listening["tracks"], "Choosing a research method")
n = next_number(method)
add_group(method, {
  "type" => "MULTIPLE_CHOICE",
  "instruction" => "Choose the correct letter, A, B or C.",
  "questions" => [
    mc(n, "How many students does Lena hope to question?", "B", [
      choice("A", "Twenty"),
      choice("B", "Two hundred"),
      choice("C", "Two thousand")
    ], "answers from two hundred students"),
    mc(n + 1, "How many interviews does the tutor suggest?", "A", [
      choice("A", "Ten"),
      choice("B", "Fifteen"),
      choice("C", "Thirty")
    ], "ten interviews to explain the surprises"),
    mc(n + 2, "What must each student sign before an interview?", "A", [
      choice("A", "A consent form"),
      choice("B", "A library card"),
      choice("C", "A lunch menu")
    ], "if each student signs a consent form")
  ]
})

trees = find_item(listening["tracks"], "Why cities plant trees")
n = next_number(trees)
add_group(trees, {
  "type" => "NOTE_COMPLETION",
  "instruction" => "Complete the notes. Write ONE WORD ONLY.",
  "wordLimit" => 1,
  "questions" => [
    typed(n, "Councils usually keep fruit trees inside {{blank}}", ["parks"], "councils usually keep them inside parks"),
    typed(n + 1, "After the first years, the main job is {{blank}}", ["inspection"], "the main job is inspection, not daily care")
  ]
})

bag = find_item(listening["tracks"], "A bag left on the train")
n = next_number(bag)
add_group(bag, {
  "type" => "FORM_COMPLETION",
  "instruction" => "Complete the form. Write ONE WORD ONLY.",
  "wordLimit" => 1,
  "questions" => [
    typed(n, "Wallet colour: {{blank}}", ["grey", "gray"], "a grey wallet"),
    typed(n + 1, "Also inside: a library {{blank}}", ["card"], "a library card"),
    typed(n + 2, "Bring photo {{blank}}", ["ID"], "Please bring photo ID")
  ]
})

walk = find_item(listening["tracks"], "Sunday walking tour")
n = next_number(walk)
add_group(walk, {
  "type" => "NOTE_COMPLETION",
  "instruction" => "Complete the notes. Write ONE WORD AND/OR A NUMBER.",
  "wordLimit" => 2,
  "questions" => [
    typed(n, "Tour length: {{blank}} minutes", ["90", "ninety"], "The tour lasts about 90 minutes"),
    typed(n + 1, "The walk starts in the old {{blank}}", ["market"], "We start in the old market"),
    typed(n + 2, "Then walk along River {{blank}}", ["Street"], "walk along River Street"),
    typed(n + 3, "The bakery stop lasts {{blank}} minutes", ["10", "ten"], "we stop at the bakery for ten minutes")
  ]
})

evening = find_item(listening["tracks"], "Choosing an evening class")
n = next_number(evening)
add_group(evening, {
  "type" => "MULTIPLE_CHOICE",
  "instruction" => "Choose the correct letter, A, B or C.",
  "questions" => [
    mc(n, "What time does the photography class start?", "A", [
      choice("A", "6.30"),
      choice("B", "8.00"),
      choice("C", "9.00")
    ], "It starts at 6.30"),
    mc(n + 1, "How much does the cooking class cost?", "B", [
      choice("A", "£9"),
      choice("B", "£90"),
      choice("C", "£190")
    ], "it costs 90 pounds"),
    mc(n + 2, "What time does the writing class end?", "B", [
      choice("A", "6.30"),
      choice("B", "8.00"),
      choice("C", "9.00")
    ], "it ends at 8")
  ]
})

garden = find_item(listening["tracks"], "The community garden")
n = next_number(garden)
add_group(garden, {
  "type" => "NOTE_COMPLETION",
  "instruction" => "Complete the notes. Write ONE WORD ONLY.",
  "wordLimit" => 1,
  "questions" => [
    typed(n, "Work sessions are on {{blank}} morning", ["Saturday"], "Work sessions are on Saturday morning"),
    typed(n + 1, "Tomatoes needed more {{blank}}", ["sun"], "Tomatoes needed more sun")
  ]
})

reading["passages"] << {
  "title" => "Jobs at the harbour market",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "Work",
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "estimatedMin" => 12,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 40,
  "content" => "The harbour office has posted three jobs.\n\nCafe assistant. Work is on weekdays and the shift starts at 7 a.m. Pay is 12 pounds an hour. No experience is needed. Ask for Lena at the pier office.\n\nCleaner. Cleaning is at weekends only. Pay is 10 pounds an hour. You must have your own transport, because the first bus arrives too late.\n\nTicket seller. The job runs through the summer, from June to August. Pay is 11 pounds an hour. You must speak English and one other language. Training is on the first Monday of June.",
  "groups" => [
    {
      "type" => "TABLE_COMPLETION",
      "instruction" => "Complete the table. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
      "wordLimit" => 2,
      "questions" => [
        typed(1, "Cafe days: {{blank}}", ["weekdays"], "Work is on weekdays"),
        typed(2, "Cafe starts at {{blank}} a.m.", ["7", "seven"], "the shift starts at 7 a.m."),
        typed(3, "Cafe pay: £{{blank}} an hour", ["12", "twelve"], "Pay is 12 pounds an hour"),
        typed(4, "Cleaner days: {{blank}}", ["weekends"], "Cleaning is at weekends only"),
        typed(5, "Cleaner pay: £{{blank}} an hour", ["10", "ten"], "Pay is 10 pounds an hour"),
        typed(6, "Ticket pay: £{{blank}} an hour", ["11", "eleven"], "Pay is 11 pounds an hour")
      ]
    },
    {
      "type" => "TRUE_FALSE_NOT_GIVEN",
      "instruction" => "Do the following statements agree with the information? Write TRUE, FALSE or NOT GIVEN.",
      "questions" => [
        judged(7, "The cafe job requires previous experience.", "FALSE", "No experience is needed."),
        judged(8, "The cleaner must have transport.", "TRUE", "You must have your own transport"),
        judged(9, "The ticket job continues all year.", "FALSE", "from June to August"),
        judged(10, "Lena is the manager of the whole harbour.", "NOT GIVEN", "The notice says to ask for Lena, not that she manages the harbour."),
        judged(11, "Ticket sellers must speak English and another language.", "TRUE", "speak English and one other language")
      ]
    }
  ]
}

reading["passages"] << {
  "title" => "A neighbourhood tool library",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "Community",
  "bandMin" => 4.5,
  "bandMax" => 6.0,
  "estimatedMin" => 15,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 41,
  "content" => "A\nA tool library lends drills, ladders and saws in the same way a book library lends novels. The one on Mill Street opened in 2018 in a former shop.\n\nB\nMembership costs 20 pounds a year. A day pass is 3 pounds. Members may borrow a tool for one week.\n\nC\nDrills and ladders are booked out on Saturdays. Wallpaper tools are much easier to find that day.\n\nD\nRetired tradespeople volunteer on Saturday morning. They show beginners how to use a tool safely. They do not do the job for you.\n\nE\nIf a tool breaks in normal use, the library repairs it. If you lose it, you pay the replacement cost.\n\nF\nThe library means fewer people buy a drill they will use once. It is not a substitute for a professional when the job is dangerous, such as roof work.",
  "groups" => [
    {
      "type" => "MATCHING_HEADINGS",
      "instruction" => "The passage has six paragraphs, A-F. Choose the correct heading for paragraphs B-F. Write i-viii.",
      "options" => [
        choice("i", "How to join and what it costs"),
        choice("ii", "Tools that are hard to borrow at weekends"),
        choice("iii", "Help from experienced volunteers"),
        choice("iv", "Who pays if something goes wrong"),
        choice("v", "What the library will not replace"),
        choice("vi", "A shop that sells new drills"),
        choice("vii", "The history of power tools"),
        choice("viii", "Free evening classes every day")
      ],
      "questions" => [
        judged(1, "Paragraph B", "i", "Membership costs 20 pounds a year."),
        judged(2, "Paragraph C", "ii", "Drills and ladders are booked out on Saturdays."),
        judged(3, "Paragraph D", "iii", "Retired tradespeople volunteer"),
        judged(4, "Paragraph E", "iv", "If you lose it, you pay the replacement cost."),
        judged(5, "Paragraph F", "v", "not a substitute for a professional when the job is dangerous")
      ]
    },
    {
      "type" => "SENTENCE_COMPLETION",
      "instruction" => "Complete the sentences. Write NO MORE THAN TWO WORDS from the passage.",
      "wordLimit" => 2,
      "questions" => [
        typed(6, "The library opened in {{blank}}.", ["2018"], "opened in 2018"),
        typed(7, "It is in a former {{blank}}.", ["shop"], "in a former shop"),
        typed(8, "Members may borrow a tool for one {{blank}}.", ["week"], "borrow a tool for one week"),
        typed(9, "On Saturdays, drills and {{blank}} are booked out.", ["ladders"], "Drills and ladders are booked out"),
        typed(10, "If you lose a tool, you pay the replacement {{blank}}.", ["cost"], "pay the replacement cost"),
        typed(11, "Roof work is given as an example of a {{blank}} job.", ["dangerous"], "when the job is dangerous, such as roof work")
      ]
    }
  ]
}

reading["passages"] << {
  "title" => "Notices at Oakfield Sports Centre",
  "level" => "A2",
  "module" => "GENERAL",
  "topic" => "Sports",
  "bandMin" => 3.5,
  "bandMax" => 5.0,
  "estimatedMin" => 10,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 42,
  "content" => "A. Pool timetable\nThe pool opens at 6 a.m. and closes at 9 p.m. Adult entry is 6 pounds. Children under 16 pay 3 pounds. The pool is closed on Monday morning until noon.\n\nB. Yoga class\nBeginners' yoga is on Tuesday at 7 p.m. in studio 2. The class lasts one hour and costs 8 pounds. Bring a mat, or hire one at the desk for 1 pound. Places must be booked by Monday.\n\nC. Lost property\nA black sports watch was found in the gym on Friday. It has a blue strap. Collect it from reception before 30 April and bring a photo ID.",
  "groups" => [
    {
      "type" => "MATCHING_INFORMATION",
      "instruction" => "Which notice contains the following information? Write A, B or C.",
      "options" => [
        choice("A", "Pool timetable"),
        choice("B", "Yoga class"),
        choice("C", "Lost property")
      ],
      "questions" => [
        judged(1, "a class that must be booked the day before", "B", "Places must be booked by Monday."),
        judged(2, "a cheaper price for children", "A", "Children under 16 pay 3 pounds."),
        judged(3, "an object that has a coloured strap", "C", "It has a blue strap."),
        judged(4, "somewhere that is shut for part of Monday", "A", "closed on Monday morning until noon")
      ]
    },
    {
      "type" => "SHORT_ANSWER",
      "instruction" => "Answer the questions. Write NO MORE THAN TWO WORDS AND/OR A NUMBER.",
      "wordLimit" => 2,
      "questions" => [
        typed(5, "What time does the pool close?", ["9 p.m.", "9pm", "9"], "closes at 9 p.m."),
        typed(6, "How much does the yoga class cost?", ["8 pounds", "£8", "8"], "costs 8 pounds"),
        typed(7, "Where is the yoga class?", ["studio 2", "studio"], "in studio 2"),
        typed(8, "What colour is the watch strap?", ["blue"], "a blue strap")
      ]
    }
  ]
}

reading["passages"] << {
  "title" => "Hiring a city bike",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "Transport",
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "estimatedMin" => 12,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 43,
  "content" => "City bikes stand at numbered docks along the river. To hire one, follow the four steps in the diagram.\n\nAt point 1 you choose a bike that is locked in the dock. Check that both tyres are hard. At point 2 you use the screen on the dock. Pay by card, or enter the code from the phone app. A single ride costs 2 pounds for thirty minutes. At point 3 the lock opens with a beep. Lift the bike straight up and out. At point 4 you will see a small basket on the front. Bags must go in the basket, not on the handlebars.\n\nReturn the bike to any dock with a green light. If the dock is full, the screen will name the next one. Helmets are not provided. Riders under 16 must be with an adult.",
  "groups" => [
    {
      "type" => "DIAGRAM_LABEL",
      "instruction" => "Label the diagram. Write NO MORE THAN TWO WORDS.",
      "wordLimit" => 2,
      "imageUrl" => "/api/media/city-bike.svg",
      "questions" => [
        typed(1, "1 {{blank}}", ["dock"], "locked in the dock"),
        typed(2, "2 {{blank}}", ["screen"], "the screen on the dock"),
        typed(3, "3 {{blank}}", ["lock"], "the lock opens with a beep"),
        typed(4, "4 {{blank}}", ["basket"], "a small basket on the front")
      ]
    },
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B or C.",
      "questions" => [
        mc(5, "How much is a single ride?", "B", [
          choice("A", "1 pound"),
          choice("B", "2 pounds for 30 minutes"),
          choice("C", "16 pounds an hour")
        ], "2 pounds for thirty minutes"),
        mc(6, "Where must bags be placed?", "A", [
          choice("A", "In the basket"),
          choice("B", "On the handlebars"),
          choice("C", "On the screen")
        ], "Bags must go in the basket, not on the handlebars."),
        mc(7, "What happens if a dock is full?", "C", [
          choice("A", "The lock stays closed"),
          choice("B", "You must return to the first dock"),
          choice("C", "The screen names another dock")
        ], "the screen will name the next one")
      ]
    }
  ]
}

reading["passages"] << {
  "title" => "The river clean-up",
  "level" => "B1",
  "module" => "GENERAL",
  "topic" => "Community",
  "bandMin" => 4.5,
  "bandMax" => 6.0,
  "estimatedMin" => 12,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 44,
  "content" => "The river clean-up takes place on the first Sunday of each month. Volunteers meet at the boathouse at 9 a.m. and finish at noon. Gloves and sacks are provided. Wear boots, because the bank is muddy.\n\nLast month the group collected 40 sacks of litter. Most of it was plastic bottles. Glass is kept separate because it cuts the sacks. Metal cans go in a third sack for recycling.\n\nChildren under 14 must stay with an adult. The organiser, Ruth Hale, asks new volunteers to arrive ten minutes early so she can explain the route. If heavy rain is forecast, she sends a text by 7 a.m. and the clean-up moves to the following Sunday.",
  "groups" => [
    {
      "type" => "MATCHING_SENTENCE_ENDINGS",
      "instruction" => "Complete each sentence with the correct ending, A-F.",
      "options" => [
        choice("A", "at the boathouse at 9 a.m."),
        choice("B", "because the bank is muddy."),
        choice("C", "because it can cut the sacks."),
        choice("D", "so Ruth can explain the route."),
        choice("E", "every Saturday afternoon."),
        choice("F", "only when the river freezes.")
      ],
      "questions" => [
        judged(1, "Volunteers meet", "A", "meet at the boathouse at 9 a.m."),
        judged(2, "Boots are needed", "B", "Wear boots, because the bank is muddy."),
        judged(3, "Glass is kept separate", "C", "Glass is kept separate because it cuts the sacks."),
        judged(4, "New volunteers should arrive early", "D", "so she can explain the route")
      ]
    },
    {
      "type" => "TRUE_FALSE_NOT_GIVEN",
      "instruction" => "Write TRUE, FALSE or NOT GIVEN.",
      "questions" => [
        judged(5, "The clean-up ends at noon.", "TRUE", "finish at noon"),
        judged(6, "Most of last month's litter was glass.", "FALSE", "Most of it was plastic bottles."),
        judged(7, "Ruth enjoys working with children.", "NOT GIVEN", "The passage does not say whether Ruth enjoys working with children.")
      ]
    }
  ]
}

def test_by(tests, title)
  row = tests["tests"].find { |t| t["title"] == title }
  raise "missing test #{title}" unless row
  row
end

def add_section(test, skill, ref_type, title)
  return if test["sections"].any? { |s| s["title"] == title }
  test["sections"] << { "skill" => skill, "refType" => ref_type, "title" => title }
end

g1 = test_by(tests, "Thi thử General số 1")
g1["description"] = "Listening 4 phần (40 câu). Reading gồm thông báo, việc làm và bài dài hơn (40 câu). Một thư và một bài Task 2. Speaking luyện riêng ở mục Speaking."
add_section(g1, "READING", "READING_PASSAGE", "Jobs at the harbour market")
add_section(g1, "READING", "READING_PASSAGE", "A neighbourhood tool library")

g2 = test_by(tests, "Thi thử General số 2")
g2["description"] = "Đề General thứ hai: Listening 4 phần (40 câu), Reading 40 câu, một thư và một bài Task 2. Không dùng lại bài của đề General số 1. Speaking luyện riêng ở mục Speaking."
add_section(g2, "READING", "READING_PASSAGE", "Notices at Oakfield Sports Centre")
add_section(g2, "READING", "READING_PASSAGE", "Hiring a city bike")
add_section(g2, "READING", "READING_PASSAGE", "The river clean-up")

a2 = test_by(tests, "Thi thử Academic số 2")
a2["description"] = "Đề Academic thứ hai: Listening 4 phần (40 câu), Reading 3 bài (40 câu), Writing Task 1 và Task 2. Không dùng lại bài của đề số 1. Speaking luyện riêng ở mục Speaking."

a1 = test_by(tests, "Thi thử Academic số 1")
a1["description"] = "Listening 4 phần (40 câu), Reading 3 bài (40 câu), Writing Task 1 và Task 2. Speaking luyện riêng ở mục Speaking."

save("reading.json", reading)
save("listening.json", listening)
save("tests.json", tests)

def count_questions(item)
  item["groups"].sum { |g| g["questions"].size }
end

puts "repair=#{count_questions(repair)} forests=#{count_questions(forests)} nights=#{count_questions(nights)} bees=#{count_questions(bees)}"
puts "waste=#{count_questions(waste)} dental=#{count_questions(dental)} market=#{count_questions(market)} method=#{count_questions(method)} trees=#{count_questions(trees)}"
puts "bag=#{count_questions(bag)} walk=#{count_questions(walk)} evening=#{count_questions(evening)} garden=#{count_questions(garden)}"
puts "passages=#{reading["passages"].size}"
