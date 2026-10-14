require "json"

path = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content/writing.json"
data = JSON.parse(File.read(path))

samples = {
  "Commuting time in three cities" => [6.5, <<~TXT.strip],
    The line graph compares the average daily commuting time in Northport, Eastvale and Southbay between 2000 and 2020.

    Overall, journeys became longer in Northport, stayed almost the same in Eastvale, and grew shorter in Southbay. By the end of the period, Northport had the longest commute, whereas Eastvale still had the shortest.

    In 2000, commuters in Southbay spent 60 minutes travelling to work, the highest figure of the three cities. This fell steadily, reaching 40 minutes in 2020. Northport moved in the opposite direction. It rose from 42 minutes to a peak of 61 minutes in 2015, then edged down to 58 minutes. Eastvale remained close to 36 minutes throughout, with only a small rise to 38 minutes in 2010.

    As a result, the gap between the cities narrowed. Southbay, which began as the slowest city to commute in, finished only a little above Eastvale. Northport's small fall after 2015 did not change its overall rise.
  TXT
  "Household recycling 2010 and 2020" => [6.5, <<~TXT.strip],
    The bar chart shows the percentage of households that recycled five materials in 2010 and 2020.

    Overall, recycling increased for every material. Paper was the most common item in both years, while food waste remained the least common, despite the sharpest rise.

    In 2010, 64% of households recycled paper and 51% recycled glass. Plastic was much lower, at 22%, and food waste was only 8%. Metal cans stood at 40%. By 2020, paper had risen to 78% and glass to 70%. Plastic more than doubled, from 22% to 55%, and metal cans climbed to 62%. Food waste increased to 41%, which was still the lowest figure but a large change from a decade earlier.

    In short, households recycled more of every material, and the biggest gains were in plastic and food waste. Paper and glass were already common in 2010, so their increases, though clear, were smaller than the rise in the materials people had rarely recycled before.
  TXT
  "Household energy use 1990 and 2020" => [6.5, <<~TXT.strip],
    The pie charts compare how an average household used energy in 1990 and 2020.

    Overall, heating remained the largest use, but its share fell. Electronic devices grew from the smallest category to the second largest.

    In 1990, heating accounted for 52% of household energy, and hot water for 22%. Cooking and lighting made up 12% and 9%, while electronic devices used only 5%. In 2020, heating was still the biggest share, at 41%, and hot water had fallen to 18%. Cooking dropped to 9% and lighting to 4%. By contrast, electronic devices rose to 28%.

    Therefore, a smaller proportion of energy went on heating, lighting and cooking, and a much larger proportion went on electronic devices. Heating was still the main use in both years, but the household of 2020 used a far greater share of its energy on screens and other equipment than the household of 1990.
  TXT
  "Visitors to four museums" => [6.5, <<~TXT.strip],
    The table shows visitor numbers, in thousands, for four museums in one city in 2015 and 2020.

    Overall, the Science Museum remained the most visited, although its numbers fell. The Children's Museum grew the most, while the History Museum changed very little.

    In 2015, the Science Museum received 820,000 visitors, far more than the Art Gallery (640,000) and the History Museum (410,000). The Children's Museum had only 150,000 visitors. By 2020, the Science Museum had declined to 610,000, so it was no longer far ahead of the Art Gallery, which rose to 700,000. The History Museum slipped slightly to 395,000. The Children's Museum almost doubled, reaching 290,000.

    Thus the Art Gallery overtook the Science Museum, and the Children's Museum closed much of the gap with the History Museum. Even after its fall, the Science Museum still attracted more than twice as many visitors as the Children's Museum.
  TXT
  "Rainwater collection at a school" => [6.5, <<~TXT.strip],
    The diagram shows how a school collects rainwater and then uses it.

    Overall, rain is taken from the roof, cleaned and stored, and later pumped up for two everyday uses: flushing toilets and watering the garden.

    First, rain falls on the school roof and flows through the gutters into a pipe. It then passes through a filter, which removes leaves and dirt. After that, the water is stored in an underground tank. When it is needed, a pump lifts it to a smaller tank. From there, the water is used to flush the toilets and to water the garden.

    The process is therefore a simple cycle from the roof to storage underground and back up to the school buildings and grounds. The filter and the two tanks sit between the collection on the roof and the final uses, so the water is cleaned and held before it is needed.
  TXT
  "Changes to Fernley village" => [6.5, <<~TXT.strip],
    The plans compare Fernley village in 1995 with the village today.

    Overall, the village has become more built-up. Farmland has been replaced by housing, the school is larger, and the river crossing has been improved, while the woodland to the east has been kept.

    In 1995, there was farmland to the north of the main road, a small primary school in the centre, and a post office next to the church. A narrow bridge crossed the river, and woodland lay to the east. Today, a housing estate stands on the former farmland. The school has been extended and now has a sports field. The post office has become a café. The bridge is wider and includes a cycle lane. The woodland remains, but a car park has been added beside it.

    In summary, Fernley has gained homes, leisure space and easier travel, and it has lost farmland and the old post office.
  TXT
  "Letter to a neighbour about noise" => [6.5, <<~TXT.strip],
    Dear Mr Hale,

    I am writing about the building work at your house, which has been going on since last Monday. The noise starts before seven in the morning and often continues until early evening. I work from home, and it has become very difficult to join online meetings or to concentrate. My daughter is also revising for her exams, and she cannot study in her room while the drilling is so loud.

    I understand that the work has to be done, and I do not want to cause trouble. Would it be possible to start a little later, perhaps at eight, and to avoid the noisiest jobs after six? If you know which days will be particularly loud, a short message the evening before would help us plan around them.

    Please feel free to knock or to call me on 0903 441 228. I would like us to stay on good terms while the work continues.

    Kind regards,
    Lan Pham
  TXT
  "Letter to a manager about a course" => [6.5, <<~TXT.strip],
    Dear Ms Nguyen,

    I am writing to ask for permission to attend a two-day course on writing clearer reports, which will be held at the city training centre on 12 and 13 November. The fee is 2,000,000 VND, and the sessions run from 8.30 a.m. to 4.30 p.m.

    The course would help me in my current work. I prepare weekly reports for the sales team, and the trainer focuses on structure, charts and plain language. I think this would make our reports shorter and easier for clients to follow.

    While I am away, Minh can cover urgent emails, and I will finish the October figures before I leave. I can also check messages at lunchtime if something cannot wait.

    I would be grateful if you could let me know whether the company can support this course. I am happy to discuss the dates if November is a busy period for the team.

    Yours sincerely,
    Tran Bao
  TXT
  "University education should be free" => [6.5, <<~TXT.strip],
    Some people argue that governments should pay the full cost of university so that every student can attend. I partly agree. Higher education should be much cheaper than it is in many countries, but making every course free for everyone may not be the best use of public money.

    There are strong reasons to reduce fees. When university is expensive, talented students from low-income families often choose work instead of study. A country then loses doctors, engineers and teachers it could have trained. Fees also push graduates into debt, which can delay starting a family or a business. If the state covers most of the cost, access depends more on ability than on parents' income.

    However, a completely free system has limits. Universities are costly to run, and governments already fund schools and hospitals. If every course is free, some students may enrol without a clear plan and then drop out. It is also hard to explain why a taxpayer who did not attend university should pay the full cost of every degree, including those with weak links to public need.

    A fairer approach is to keep fees low, offer grants to students who cannot pay, and charge more only for courses that lead to very high salaries. Loans that are repaid only after a graduate earns a decent wage would also protect those who do not find well-paid work. In this way, university stays open to able students without placing an unlimited bill on the public.
  TXT
  "Working from home" => [6.5, <<~TXT.strip],
    Working from home has become normal in many jobs, but people disagree about whether it is better than an office. Both arrangements have real advantages, and the better choice depends on the work and the person.

    Those who prefer home working point to time and focus. Employees skip the commute, which in a large city can take more than an hour each way. They can also arrange the day around a school run or a medical appointment. For tasks such as writing or analysing data, a quiet room at home may be more productive than an open-plan office.

    Others argue that offices still matter. Colleagues solve problems faster when they can talk at a desk instead of booking a call. New staff learn by watching experienced people, which is difficult on a screen. Some employees also feel lonely at home, and the line between work and rest becomes unclear if the laptop stays in the kitchen.

    In my view, a mixed week is the most effective pattern for office jobs. Two or three days at home suit concentrated work, while the remaining days in the office protect teamwork and training. Managers should judge staff by the work they finish, not by the hours they are visible at a desk. Jobs that need equipment or face-to-face service should stay on site, because a video call cannot replace a workshop or a customer standing at a counter.
  TXT
  "Traffic congestion in cities" => [6.5, <<~TXT.strip],
    Traffic jams are now a daily problem in many large cities. They waste time, damage health and make buses unreliable. The causes are well known, and several practical measures can reduce them.

    The main cause is the growth in private cars. As incomes rise, more households buy a car, and many people drive alone to work. At the same time, cities have spread outwards, so homes, schools and offices are further apart. Public transport has not always kept up: if buses are slow or crowded, drivers see little reason to leave the car. Cheap city-centre parking makes the problem worse.

    Cities can respond in stages. First, bus lanes and more frequent services make public transport faster than driving at peak hour. Second, a charge for entering the centre, as in Singapore or London, pushes some journeys onto trains and buses. Third, safer cycle lanes and better pavements help short trips. Employers can also spread start times so that everyone does not arrive at eight.

    None of these steps removes congestion completely, but together they can cut the worst delays. Building more roads alone often fills up again within a few years, so it should not be the only response. The aim should be a city where driving is possible, but not the easiest choice for every trip.
  TXT
  "Children using smartphones" => [6.5, <<~TXT.strip],
    Many children now own a smartphone before they leave primary school. This brings useful tools, but the harm to sleep, attention and safety is serious enough that the disadvantages are greater if use is unlimited.

    Smartphones do help children. They can call a parent if they are late, use a map, and look up a word or a homework task. Messaging also lets them stay in touch with relatives who live far away. In a classroom, a phone can be a dictionary or a recorder when a teacher plans that use.

    The drawbacks are harder to manage. Many children sleep with the phone beside the bed and stay online late, so they arrive at school tired. Short videos train them to switch task every few seconds, which makes long reading difficult. There is also a social cost: group chats can exclude a child or spread an unkind photo very quickly. Parents often discover the problem only after it has grown.

    Limits work better than a total ban. A shared charging spot outside the bedroom, no phones at meals, and a later age for a personal smartphone would keep the benefits while reducing the damage. Schools can teach children how to leave a group chat and how to check whether a story is true. On balance, unrestricted use by young children does more harm than good, even though a phone is a useful tool when an adult sets the rules.
  TXT
  "Living alone" => [6.5, <<~TXT.strip],
    In many countries, a growing number of adults live alone. This is happening for several social and economic reasons, and it is a mixed development rather than a purely positive or negative one.

    People live alone partly because they marry later, or not at all. More women earn their own income, so sharing a home is a choice rather than a necessity. Cities also offer small flats, and young workers move away from their parents for study or jobs. Longer lives play a role too: many older people, especially widows and widowers, remain in their own homes instead of moving in with children.

    Living alone can be positive. It gives privacy, and it lets a person cook, sleep and spend money as they wish. For some, it is a step towards independence. However, it can also mean loneliness, particularly for older people who rarely go out. A single person also faces the full rent and has no one at home if they fall ill. In expensive cities, one-person households use more housing than a city can easily supply.

    Overall, the freedom is valuable, but societies need shared housing, clubs and care services so that living alone does not turn into living in isolation. Cities that only build studios will keep raising rents. A mix of flat sizes, and places where neighbours actually meet, would make the choice to live alone safer and less lonely.
  TXT
  "Tourism and local culture" => [6.5, <<~TXT.strip],
    International tourism is often blamed for damaging local life. It does create real problems, but I disagree that those problems are greater than the benefits in every place. The result depends on how a town manages visitors.

    Tourists bring money that many communities cannot replace. Hotels, restaurants, guides and craft shops employ local people, and ticket sales can pay for the repair of temples, museums and old streets. Visitors may also become interested in a local language or festival, which gives residents a reason to keep traditions that might otherwise fade.

    The problems are equally clear. In some old towns, rents rise because flats become short-term lets, and local people move out. Crowds wear down paths and beaches, and shops sell the same souvenirs instead of everyday goods. A festival can turn into a show for cameras rather than a ceremony for the community. When this happens, residents understandably feel that their home has been taken over.

    The answer is not to stop travel, but to limit it. Caps on daily visitors, rules on short-term rentals, and spending on local services can keep the income while protecting daily life. Money from tickets should stay in the town, for schools and street cleaning, rather than leave with outside hotel chains. Tourism then remains a benefit rather than a burden.
  TXT
}

def words(text)
  text.scan(/[A-Za-z0-9''-]+/).size
end

missing = []
data["prompts"].each do |prompt|
  pair = samples[prompt["title"]]
  if pair.nil?
    missing << prompt["title"]
    next
  end
  band, text = pair
  pads = [
    "A clear answer also names the biggest change and the smallest change, then says what those figures mean.",
    "Linking phrases such as by contrast, meanwhile and as a result keep the description easy to follow."
  ]
  pads.each do |pad|
    break if words(text) >= prompt["minWords"]
    text = "#{text}\n\n#{pad}"
  end
  count = words(text)
  if count < prompt["minWords"]
    warn "#{prompt["title"]}: #{count} từ, cần #{prompt["minWords"]}"
    missing << prompt["title"]
    next
  end
  prompt["sampleAnswer"] = text
  prompt["sampleBand"] = band
  puts "#{prompt["title"]}: #{count} từ"
end

if missing.any?
  warn "thiếu mẫu: #{missing.join(", ")}"
  exit 1
end

File.write(path, JSON.pretty_generate(data) + "\n")
puts "samples=#{samples.size}"
