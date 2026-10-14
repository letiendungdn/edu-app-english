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
  "title" => "Repair cafes and the right to fix",
  "level" => "B2",
  "module" => "ACADEMIC",
  "topic" => "Society",
  "bandMin" => 5.5,
  "bandMax" => 7.0,
  "estimatedMin" => 20,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 20,
  "content" => <<~TXT.strip,
    On a wet Saturday in Bristol, a queue forms outside a church hall. People are not waiting for a concert. They are carrying toasters, lamps and a laptop that will not charge. Inside, volunteers with screwdrivers sit at long tables. This is a repair cafe, a place where neighbours help each other mend things instead of throwing them away.

    The first repair cafe opened in Amsterdam in 2009. The idea spread quickly. Organisers say there are now thousands of similar events across Europe, North America and parts of Asia. Most are free. Visitors pay nothing for the labour, though they are often asked to bring a small donation for tea and spare parts. The point is not to replace professional shops. It is to keep simple objects in use for a few more years, and to show people that a broken switch is not always the end of a machine.

    Researchers who have watched these events argue that the environmental gain is real but easy to overstate. A repaired kettle saves the energy and materials that would have gone into a new one. It does not, however, cancel the impact of the much larger things people buy, such as cars and heating systems. One Dutch study of repair cafes found that about two thirds of the items brought in were fixed on the day. The rest needed a part that nobody had, or were too badly damaged. Even the failures taught something: visitors left knowing why the object had died.

    A harder problem is design. Many modern products are glued shut, or use screws that ordinary tools cannot turn. Campaigners call this the "right to fix". They want manufacturers to sell spare parts and to publish basic repair guides. Some governments have started to listen. France now requires a repair score on certain appliances, a number that tells shoppers how easy a product is to mend. Critics say the score is still too narrow, because it ignores how long software updates will last.

    The volunteers in Bristol are more practical than political. A retired electrician shows a student how to test a fuse. A teenager leaves with a lamp that works and a small notebook of what she did. The cafe will be back next month. The queue, the organisers expect, will be just as long.
  TXT
  "groups" => [
    {
      "type" => "TRUE_FALSE_NOT_GIVEN",
      "instruction" => "Do the following statements agree with the information in the passage? Write TRUE, FALSE or NOT GIVEN.",
      "questions" => [
        { "number" => 1, "prompt" => "The first repair cafe opened in Bristol.", "answers" => ["FALSE"], "evidence" => "The first repair cafe opened in Amsterdam in 2009." },
        { "number" => 2, "prompt" => "Visitors are usually charged for the repair work itself.", "answers" => ["FALSE"], "evidence" => "Visitors pay nothing for the labour" },
        { "number" => 3, "prompt" => "About two thirds of items in one Dutch study were repaired on the same day.", "answers" => ["TRUE"], "evidence" => "about two thirds of the items brought in were fixed on the day" },
        { "number" => 4, "prompt" => "Repairing a kettle removes the environmental cost of owning a car.", "answers" => ["FALSE"], "evidence" => "It does not, however, cancel the impact of the much larger things people buy, such as cars" },
        { "number" => 5, "prompt" => "France shows a repair score on some appliances.", "answers" => ["TRUE"], "evidence" => "France now requires a repair score on certain appliances" },
        { "number" => 6, "prompt" => "The Bristol volunteers plan to open a permanent shop.", "answers" => ["NOT GIVEN"], "evidence" => "The passage says the cafe will return next month, not that a shop will open." }
      ]
    },
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B, C or D.",
      "questions" => [
        {
          "number" => 7,
          "prompt" => "What is the main aim of a repair cafe?",
          "answers" => ["B"],
          "options" => [
            { "key" => "A", "text" => "To train people for jobs in electronics shops" },
            { "key" => "B", "text" => "To keep everyday objects in use for longer" },
            { "key" => "C", "text" => "To sell spare parts at a profit" },
            { "key" => "D", "text" => "To replace professional repair businesses" }
          ]
        },
        {
          "number" => 8,
          "prompt" => "Why do some repairs fail on the day?",
          "answers" => ["C"],
          "options" => [
            { "key" => "A", "text" => "Visitors refuse to donate money" },
            { "key" => "B", "text" => "The volunteers only work on laptops" },
            { "key" => "C", "text" => "A part is missing or the damage is too serious" },
            { "key" => "D", "text" => "The church hall closes at noon" }
          ]
        },
        {
          "number" => 9,
          "prompt" => "What do campaigners want manufacturers to do?",
          "answers" => ["A"],
          "options" => [
            { "key" => "A", "text" => "Sell spare parts and publish repair guides" },
            { "key" => "B", "text" => "Glue products shut so they last longer" },
            { "key" => "C", "text" => "Stop selling appliances in France" },
            { "key" => "D", "text" => "Offer free tea at repair events" }
          ]
        },
        {
          "number" => 10,
          "prompt" => "What criticism is made of the French repair score?",
          "answers" => ["D"],
          "options" => [
            { "key" => "A", "text" => "It is only available in Bristol" },
            { "key" => "B", "text" => "It is too expensive for students" },
            { "key" => "C", "text" => "It covers cars and heating systems" },
            { "key" => "D", "text" => "It does not consider how long software updates continue" }
          ]
        }
      ]
    }
  ]
}, "title")

added["reading"] += add_unique(reading["passages"], {
  "title" => "Tiny forests in crowded cities",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Nature",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 20,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 21,
  "content" => <<~TXT.strip,
    A patch of land the size of a tennis court does not look like a forest. Yet in cities from Tokyo to Utrecht, planners are planting dense groups of native trees and shrubs and calling them tiny forests. The method was popularised by the Japanese botanist Akira Miyawaki, who argued that a carefully chosen mix of local species, planted close together, can form a stable woodland much faster than a conventional park plantation.

    The appeal for city councils is obvious. A tiny forest fits into a schoolyard, a roadside verge or the corner of a car park. Within a few years the young trees shade the soil, and the leaf litter begins to hold water after heavy rain. Teachers use the plots for biology lessons. Residents say the sites are cooler in summer than the surrounding pavement. Birds and insects arrive before the trees are tall, because the planting includes flowers and berry shrubs as well as canopy species.

    Evidence for the wider claims is still uneven. Supporters sometimes say a tiny forest absorbs as much carbon as a mature woodland of the same size. Forest scientists treat that comparison with caution. Young trees do grow quickly, but most of the carbon in an old forest sits in the soil and in large trunks, which a ten-year-old plot has not yet produced. A review of urban planting projects in the Netherlands found clear gains in shade and in the number of plant species. It found only modest, hard-to-measure changes in city-wide air temperature.

    There are practical limits too. The Miyawaki method asks for deep soil preparation and a high number of seedlings, so the cost per square metre is higher than scattering a few street trees. If the species are poorly chosen, the thick planting becomes a thicket that neighbours dislike, and the council must pay to thin it. Watering is essential in the first two summers. After that, advocates say, the plot should survive with little care. Councils that skip the early watering often lose the very trees the brochure promised.

    None of this makes the idea worthless. In a city that cannot spare a large park, a small native woodland is better than another sealed car park. The honest case is local: shade, habitat, a place for children to learn the names of trees. It is not a substitute for protecting existing forests outside the city.
  TXT
  "groups" => [
    {
      "type" => "YES_NO_NOT_GIVEN",
      "instruction" => "Do the following statements agree with the views of the writer? Write YES, NO or NOT GIVEN.",
      "questions" => [
        { "number" => 1, "prompt" => "A tiny forest can be planted in a very small urban space.", "answers" => ["YES"], "evidence" => "A tiny forest fits into a schoolyard, a roadside verge or the corner of a car park." },
        { "number" => 2, "prompt" => "The writer believes a young tiny forest stores as much carbon as an old forest of the same area.", "answers" => ["NO"], "evidence" => "Forest scientists treat that comparison with caution... a ten-year-old plot has not yet produced" },
        { "number" => 3, "prompt" => "The Dutch review found a large drop in city-wide temperature.", "answers" => ["NO"], "evidence" => "only modest, hard-to-measure changes in city-wide air temperature" },
        { "number" => 4, "prompt" => "Miyawaki planting is cheaper per square metre than planting a few street trees.", "answers" => ["NO"], "evidence" => "the cost per square metre is higher than scattering a few street trees" },
        { "number" => 5, "prompt" => "The writer thinks tiny forests should replace forests outside cities.", "answers" => ["NO"], "evidence" => "It is not a substitute for protecting existing forests outside the city." }
      ]
    },
    {
      "type" => "SUMMARY_COMPLETION",
      "instruction" => "Complete the summary. Write NO MORE THAN TWO WORDS from the passage for each answer.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 6, "prompt" => "The method was popularised by the botanist Akira {{blank}}.", "answers" => ["Miyawaki"] },
        { "number" => 7, "prompt" => "After a few years, leaf litter helps the soil hold {{blank}} following heavy rain.", "answers" => ["water"] },
        { "number" => 8, "prompt" => "Most carbon in an old forest is held in the soil and in large {{blank}}.", "answers" => ["trunks"] },
        { "number" => 9, "prompt" => "Poorly chosen species can turn the planting into a {{blank}} that neighbours dislike.", "answers" => ["thicket"] },
        { "number" => 10, "prompt" => "Councils that skip early {{blank}} often lose the young trees.", "answers" => ["watering"] }
      ]
    }
  ]
}, "title")

added["reading"] += add_unique(reading["passages"], {
  "title" => "The cost of working at night",
  "level" => "C1",
  "module" => "ACADEMIC",
  "topic" => "Health",
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "estimatedMin" => 20,
  "source" => "EDU APP English",
  "license" => "original",
  "sortOrder" => 22,
  "content" => <<~TXT.strip,
    Hospitals, ports and bakeries do not close when the sun goes down. Someone has to staff them. In wealthy countries, roughly one worker in five sometimes works a night shift. The arrangement keeps services running, but a growing body of research suggests it carries a health cost that rotas rarely show.

    The human body clock expects sleep in the dark and food during the day. Night work pushes against both habits. People who finish a shift at dawn often sleep in short blocks, and the sleep they get is lighter. Over months, that shortage is linked with higher rates of obesity, type 2 diabetes and some cardiovascular disease. The International Agency for Research on Cancer has classed night shift work as probably carcinogenic, mainly because of the long-term disruption of circadian rhythms, not because of one bad week.

    Not every night worker is affected in the same way. Dr Helen Okonkwo, who studies hospital staff in Lagos, points out that nurses with some control over their rota report less fatigue than those whose shifts are imposed at short notice. A second line of research, led by the chronobiologist Marco Rossi in Milan, finds that people he calls "night types", who naturally stay up late, adapt a little better than strong morning types. Adaptation is only partial. Even night types still show disturbed glucose control after a run of night shifts.

    Employers have tried several fixes. Bright light during the shift and very dark bedrooms afterwards help some people move their clock. Short naps of about twenty minutes, taken before 4 a.m., improve alertness without making it harder to sleep later. What does not work, according to a review by the occupational physician Samuel Berg, is simply telling staff to "catch up at the weekend". Two long lie-ins do not repay five short sleeps, and the Monday return to nights becomes harder, not easier.

    Berg argues that the honest response is to treat night work as a limited resource. He recommends capping long runs of nights, publishing rotas at least two weeks ahead, and paying a real premium rather than a token one. Okonkwo agrees about notice periods but is wary of bans: in a city with too few nurses, a ban on nights would close wards. Vescovi, for his part, wants shift design to start from biology, with the heaviest tasks placed earlier in the night when attention is higher. None of them claims that a perfect rota exists. They claim that a careless one is a choice.
  TXT
  "groups" => [
    {
      "type" => "MATCHING_FEATURES",
      "instruction" => "Which researcher expresses the following views? Write A, B or C.",
      "options" => [
        { "key" => "A", "text" => "Helen Okonkwo" },
        { "key" => "B", "text" => "Marco Vescovi" },
        { "key" => "C", "text" => "Samuel Berg" }
      ],
      "questions" => [
        { "number" => 1, "prompt" => "Nurses who can influence their rota feel less tired.", "answers" => ["A"], "evidence" => "nurses with some control over their rota report less fatigue" },
        { "number" => 2, "prompt" => "People who naturally stay up late adjust somewhat more easily.", "answers" => ["B"], "evidence" => "night types, who naturally stay up late, adapt a little better" },
        { "number" => 3, "prompt" => "Sleeping late at the weekend does not repay a week of short nights.", "answers" => ["C"], "evidence" => "Two long lie-ins do not repay five short sleeps" },
        { "number" => 4, "prompt" => "Forbidding night shifts could shut hospital wards where staff are scarce.", "answers" => ["A"], "evidence" => "a ban on nights would close wards" },
        { "number" => 5, "prompt" => "The most demanding jobs should be scheduled earlier in the night.", "answers" => ["B"], "evidence" => "the heaviest tasks placed earlier in the night" }
      ]
    },
    {
      "type" => "SENTENCE_COMPLETION",
      "instruction" => "Complete the sentences. Write NO MORE THAN TWO WORDS from the passage.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 6, "prompt" => "About one worker in five in wealthy countries sometimes works a {{blank}}.", "answers" => ["night shift"] },
        { "number" => 7, "prompt" => "Night work has been classed as probably {{blank}} because it disturbs body rhythms.", "answers" => ["carcinogenic"] },
        { "number" => 8, "prompt" => "Even people who adapt still show disturbed {{blank}} control.", "answers" => ["glucose"] },
        { "number" => 9, "prompt" => "A nap of about twenty minutes before 4 a.m. can improve {{blank}}.", "answers" => ["alertness"] },
        { "number" => 10, "prompt" => "Berg wants employers to publish rotas at least two weeks {{blank}}.", "answers" => ["ahead"] }
      ]
    }
  ]
}, "title")

dentist = <<~TXT.strip
  Receptionist: Good morning, City Dental. How can I help you?
  Patient: Hello. I'd like to book a check-up. My name is Anna Cole.
  Receptionist: Could you spell the surname?
  Patient: C-O-L-E. And my phone number is 0771 438 920.
  Receptionist: Thank you. The next free appointments are Thursday at ten, or Friday at two.
  Patient: Thursday at ten, please.
  Receptionist: That's with Dr Khan. A check-up costs forty-five pounds. Please arrive ten minutes early and bring a photo ID.
  Patient: Is there parking?
  Receptionist: The clinic car park is full by nine, so please use the station car park across the road. It is free for patients.
TXT

added["listening"] += add_unique(listening["tracks"], {
  "title" => "A check-up at City Dental",
  "level" => "B1",
  "ieltsPart" => 1,
  "bandMin" => 4.0,
  "bandMax" => 5.5,
  "durationSec" => 90,
  "sortOrder" => 20,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => dentist,
  "groups" => [
    {
      "type" => "FORM_COMPLETION",
      "instruction" => "Complete the form. Write ONE WORD AND/OR A NUMBER for each answer.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "Surname: {{blank}}", "answers" => ["Cole"] },
        { "number" => 2, "prompt" => "Phone: {{blank}}", "answers" => ["0771 438 920", "0771438920"] },
        { "number" => 3, "prompt" => "Day: {{blank}}", "answers" => ["Thursday"] },
        { "number" => 4, "prompt" => "Time: {{blank}}", "answers" => ["10", "ten"] },
        { "number" => 5, "prompt" => "Dentist: Dr {{blank}}", "answers" => ["Khan"] },
        { "number" => 6, "prompt" => "Price of check-up: £{{blank}}", "answers" => ["45", "forty-five"] },
        { "number" => 7, "prompt" => "Arrive {{blank}} minutes early", "answers" => ["10", "ten"] },
        { "number" => 8, "prompt" => "Parking: {{blank}} car park", "answers" => ["station"] }
      ]
    }
  ]
}, "title")

market = <<~TXT.strip
  Guide: Welcome to the Friday night market. The market opens at six and the last food stall closes at eleven. Entry is free, but the cookery demonstration at eight costs five pounds and must be booked at the information tent.
  The north row is for hot food. The busiest stall is the noodle stall, which usually sells out by nine thirty. If you want a quieter meal, the soup stall at the far end has seats.
  On the south row you will find clothes and handmade soap. Please do not bring dogs into the south row, because of the food samples. Bicycles can be left at the green rack beside the station entrance.
  If it rains, the music stage moves inside the old post office. Toilets are behind the clock tower. Lost children should be taken to the information tent, where a member of staff called Priya is on duty all evening.
TXT

added["listening"] += add_unique(listening["tracks"], {
  "title" => "Friday night market",
  "level" => "B2",
  "ieltsPart" => 2,
  "bandMin" => 5.0,
  "bandMax" => 6.5,
  "durationSec" => 120,
  "sortOrder" => 21,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => market,
  "groups" => [
    {
      "type" => "NOTE_COMPLETION",
      "instruction" => "Complete the notes. Write ONE WORD AND/OR A NUMBER for each answer.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "Market opens at {{blank}}", "answers" => ["6", "six"] },
        { "number" => 2, "prompt" => "Food stalls close at {{blank}}", "answers" => ["11", "eleven"] },
        { "number" => 3, "prompt" => "Cookery demonstration costs £{{blank}}", "answers" => ["5", "five"] },
        { "number" => 4, "prompt" => "Book the demonstration at the information {{blank}}", "answers" => ["tent"] },
        { "number" => 5, "prompt" => "Noodle stall often sells out by {{blank}}", "answers" => ["9.30", "9:30", "nine thirty"] },
        { "number" => 6, "prompt" => "Do not take {{blank}} into the south row", "answers" => ["dogs"] },
        { "number" => 7, "prompt" => "If it rains, the stage moves to the old {{blank}}", "answers" => ["post office"] },
        { "number" => 8, "prompt" => "Lost children: ask for {{blank}}", "answers" => ["Priya"] }
      ]
    }
  ]
}, "title")

methods = <<~TXT.strip
  Tutor: You both want to study how students choose their lunch. Have you decided on a method?
  Lena: I prefer a questionnaire. We can collect answers from two hundred students in one week, and the canteen manager will email the link.
  Omar: The numbers would be tidy, but people rush those forms. I want to sit in the canteen for three lunchtimes and write down what they actually pick.
  Lena: Observation will not tell us why they choose. A short interview, maybe fifteen people, would explain the reasons.
  Tutor: You do not have time for all three. The department deadline is the twelfth of May. I suggest the questionnaire for the main result, and ten interviews to explain the surprises. Leave the observation for a later project.
  Omar: Can we record the interviews?
  Tutor: Yes, if each student signs a consent form. Store the files on the university drive, not on a personal laptop.
TXT

added["listening"] += add_unique(listening["tracks"], {
  "title" => "Choosing a research method",
  "level" => "C1",
  "ieltsPart" => 3,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 120,
  "sortOrder" => 22,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => methods,
  "groups" => [
    {
      "type" => "MULTIPLE_CHOICE",
      "instruction" => "Choose the correct letter, A, B or C.",
      "questions" => [
        {
          "number" => 1,
          "prompt" => "What are the students studying?",
          "answers" => ["B"],
          "options" => [
            { "key" => "A", "text" => "How the canteen hires staff" },
            { "key" => "B", "text" => "How students choose lunch" },
            { "key" => "C", "text" => "How much lunch costs" }
          ]
        },
        {
          "number" => 2,
          "prompt" => "Why does Lena like a questionnaire?",
          "answers" => ["A"],
          "options" => [
            { "key" => "A", "text" => "It can reach many students quickly" },
            { "key" => "B", "text" => "It explains every reason in depth" },
            { "key" => "C", "text" => "It does not need the manager's help" }
          ]
        },
        {
          "number" => 3,
          "prompt" => "What does Omar want to do in the canteen?",
          "answers" => ["C"],
          "options" => [
            { "key" => "A", "text" => "Interview the manager" },
            { "key" => "B", "text" => "Serve food for three days" },
            { "key" => "C", "text" => "Watch what students actually choose" }
          ]
        },
        {
          "number" => 4,
          "prompt" => "What does the tutor tell them to drop for now?",
          "answers" => ["A"],
          "options" => [
            { "key" => "A", "text" => "Observation" },
            { "key" => "B", "text" => "The questionnaire" },
            { "key" => "C", "text" => "The interviews" }
          ]
        },
        {
          "number" => 5,
          "prompt" => "When is the department deadline?",
          "answers" => ["B"],
          "options" => [
            { "key" => "A", "text" => "The second of May" },
            { "key" => "B", "text" => "The twelfth of May" },
            { "key" => "C", "text" => "The twentieth of May" }
          ]
        },
        {
          "number" => 6,
          "prompt" => "Where must the recordings be stored?",
          "answers" => ["C"],
          "options" => [
            { "key" => "A", "text" => "On a personal laptop" },
            { "key" => "B", "text" => "In the canteen office" },
            { "key" => "C", "text" => "On the university drive" }
          ]
        }
      ]
    }
  ]
}, "title")

trees = <<~TXT.strip
  Lecturer: Cities plant trees for reasons that go well beyond appearance. A mature street tree can cut the temperature of the pavement beneath it by several degrees, which matters in heat waves. The leaves also catch fine dust. Studies in several European cities found lower particulate levels on tree-lined roads than on bare ones of the same width, though the difference is small on very windy days.
  Roots are a more awkward gift. They hold soil on slopes and take up storm water, so streets flood less. They also lift pavements and enter old drains. That is why new planting schemes now use underground crates, which guide the roots away from the pipes.
  Species choice decides whether the tree is still there in thirty years. Plane trees tolerate pollution and pruning, which is why so many avenues use them. They are a poor choice beside hospitals, because their fine hairs irritate some patients. Fruit trees feed birds, but fallen fruit makes pavements slippery, so councils usually keep them inside parks.
  The expensive mistake is planting and then forgetting. A young tree needs water for the first three summers. After that, the main job is inspection, not daily care. Cities that budget only for the planting day lose a large share of the trees before they are big enough to shade anyone.
TXT

added["listening"] += add_unique(listening["tracks"], {
  "title" => "Why cities plant trees",
  "level" => "C1",
  "ieltsPart" => 4,
  "bandMin" => 6.0,
  "bandMax" => 7.5,
  "durationSec" => 150,
  "sortOrder" => 23,
  "source" => "EDU APP English (giọng đọc máy)",
  "license" => "original",
  "transcript" => trees,
  "groups" => [
    {
      "type" => "NOTE_COMPLETION",
      "instruction" => "Complete the notes. Write NO MORE THAN TWO WORDS for each answer.",
      "wordLimit" => 2,
      "questions" => [
        { "number" => 1, "prompt" => "A mature tree can lower the pavement {{blank}}", "answers" => ["temperature"] },
        { "number" => 2, "prompt" => "Leaves catch fine {{blank}}", "answers" => ["dust"] },
        { "number" => 3, "prompt" => "The dust benefit is small on very {{blank}} days", "answers" => ["windy"] },
        { "number" => 4, "prompt" => "Roots can enter old {{blank}}", "answers" => ["drains"] },
        { "number" => 5, "prompt" => "Underground crates guide roots away from the {{blank}}", "answers" => ["pipes"] },
        { "number" => 6, "prompt" => "Plane trees are a poor choice beside {{blank}}", "answers" => ["hospitals"] },
        { "number" => 7, "prompt" => "Fallen fruit makes pavements {{blank}}", "answers" => ["slippery"] },
        { "number" => 8, "prompt" => "Young trees need water for the first three {{blank}}", "answers" => ["summers"] }
      ]
    }
  ]
}, "title")

library_sample = <<~TXT.strip
  The bar chart compares the number of books borrowed from four public libraries in 2015 and 2024, measured in thousands of loans.
  Overall, borrowing fell sharply at the Central Library, while the three smaller libraries all lent more books. By 2024, West Library had almost caught Central, which was no longer far ahead of the others.
  In 2015, Central recorded 120,000 loans, more than twice the figure for East and four times the figure for North. West was the least used library, at 40,000 loans. East stood at 55,000.
  By 2024 the pattern had changed. Central's loans dropped to 90,000, a fall of 30,000. West more than doubled, rising to 85,000, and North climbed from 30,000 to 70,000. East increased only slightly, from 55,000 to 60,000, and finished as the quietest of the four.
  The gap between the busiest and the quietest library therefore narrowed. Central remained first, but its lead over West was only 5,000 loans, compared with 80,000 nine years earlier.
TXT

raise "library sample #{words(library_sample)}" if words(library_sample) < 150

added["writing"] += add_unique(writing["prompts"], {
  "module" => "ACADEMIC",
  "task" => "TASK1",
  "taskKind" => "BAR",
  "sortOrder" => 20,
  "title" => "Library loans in 2015 and 2024",
  "topic" => "Education",
  "minWords" => 150,
  "prompt" => "The bar chart below shows the number of books borrowed from four public libraries in 2015 and 2024.\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant.",
  "chartData" => {
    "type" => "bar",
    "unit" => "thousands of loans",
    "labels" => ["Central", "West", "East", "North"],
    "series" => [
      { "name" => "2015", "values" => [120, 40, 55, 30] },
      { "name" => "2024", "values" => [90, 85, 60, 70] }
    ]
  },
  "sampleAnswer" => library_sample,
  "sampleBand" => 6.5
}, "title")

transport_sample = <<~TXT.strip
  Some people argue that city buses and trains should be free for everyone. I partly agree. Free local transport would cut traffic and help people on low incomes, but only if the service is frequent and the city can pay for it without starving other public needs.
  The strongest argument is practical. When fares disappear, some drivers leave their cars at home. Fewer cars mean less congestion and cleaner air in the streets where people live. A second benefit is fairness. A nurse on a night shift and a student with a long commute both depend on the network. If the ticket price is a real part of their weekly budget, a free pass is not a luxury. It is the difference between taking the job and turning it down.
  There are serious objections. A free system still costs money for drivers, fuel, tracks and repairs. If that money is taken from schools or hospitals, the city has not become fairer. It has only moved the bill. Free travel can also become crowded travel. If buses are already full at eight in the morning, removing the fare will not create more seats. Cities that have tried free fares have usually had to buy more vehicles at the same time, which is the expensive part of the policy.
  A better version is targeted rather than universal. Off-peak travel could be free, and people on low incomes could receive a pass, while peak-hour tickets stay cheap but not zero. The income from those tickets would keep the frequent services that make people willing to leave the car. In short, free transport is a good idea when it is funded honestly and matched with enough buses. Without that, it is a promise the timetable cannot keep.
TXT

raise "transport sample #{words(transport_sample)}" if words(transport_sample) < 250

added["writing"] += add_unique(writing["prompts"], {
  "module" => "BOTH",
  "task" => "TASK2",
  "taskKind" => "OPINION",
  "sortOrder" => 21,
  "title" => "Free public transport in cities",
  "topic" => "Transport",
  "minWords" => 250,
  "prompt" => "Some people believe that public transport in cities should be free for everyone. To what extent do you agree or disagree?",
  "sampleAnswer" => transport_sample,
  "sampleBand" => 6.5
}, "title")

added["tests"] += add_unique(tests["tests"], {
  "kind" => "MOCK",
  "module" => "ACADEMIC",
  "title" => "Thi thử Academic số 2",
  "description" => "Đề Academic thứ hai, không dùng lại bài của đề số 1: Listening 4 phần mới, Reading 3 bài mới, Writing Task 1 và Task 2 mới. Speaking luyện riêng ở mục Speaking.",
  "durationMin" => 150,
  "sortOrder" => 3,
  "sections" => [
    { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "A check-up at City Dental" },
    { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "Friday night market" },
    { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "Choosing a research method" },
    { "skill" => "LISTENING", "refType" => "LISTENING_TRACK", "title" => "Why cities plant trees" },
    { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "Repair cafes and the right to fix" },
    { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "Tiny forests in crowded cities" },
    { "skill" => "READING", "refType" => "READING_PASSAGE", "title" => "The cost of working at night" },
    { "skill" => "WRITING", "refType" => "WRITING_PROMPT", "title" => "Library loans in 2015 and 2024" },
    { "skill" => "WRITING", "refType" => "WRITING_PROMPT", "title" => "Free public transport in cities" }
  ]
}, "title")

File.write("#{root}/reading.json", JSON.pretty_generate(reading) + "\n")
File.write("#{root}/listening.json", JSON.pretty_generate(listening) + "\n")
File.write("#{root}/writing.json", JSON.pretty_generate(writing) + "\n")
File.write("#{root}/tests.json", JSON.pretty_generate(tests) + "\n")
puts added.map { |k, v| "#{k}=#{v}" }.join(" ")
puts "library_words=#{words(library_sample)} transport_words=#{words(transport_sample)}"
