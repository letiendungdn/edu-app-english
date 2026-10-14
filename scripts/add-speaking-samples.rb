# frozen_string_literal: true

require "json"

PATH = "backend/src/main/resources/content/speaking.json"

ANSWERS = {
  "Where is your hometown, and what is it like?" => <<~TXT.strip,
    My hometown is a medium-sized city in the north of Vietnam, about two hours from the coast. It is not a famous place, but it is easy to live in. The centre has a lake, a market and quite a few cafes, and most people get around by motorbike. Summers are hot and wet, while winters are grey and a little cold. I like it because my family is there and I still know the streets.
  TXT
  "What do you like most about living there?" => <<~TXT.strip,
    What I like most is that daily life is convenient. I can walk to a market in ten minutes, and food is cheap and fresh. The city is also big enough to have a library and a few parks, but it is not as crowded as Hanoi. In the evening the lake path is full of people walking, which I find relaxing. I would miss that if I moved away.
  TXT
  "Do you work or are you a student? Tell me a little about it." => <<~TXT.strip,
    I am a student at a university in the city. I study business, and most of my classes are in the morning. In the afternoon I usually go to the library or work on group projects. The course is practical, so we often look at real companies rather than only reading theory. It is busy around exam time, but I enjoy it.
  TXT
  "What would you like to change about your job or your studies?" => <<~TXT.strip,
    I would like the timetable to be more even. Some weeks we have three deadlines at once, and then the next week is almost empty. I would also like smaller classes, because in a room of sixty people it is hard to ask a question. Apart from that, the teachers are helpful and the subjects are interesting.
  TXT
  "What do you usually do in your free time?" => <<~TXT.strip,
    In my free time I usually cook, listen to music, or go for a walk if the weather is good. At the weekend I sometimes meet a friend for coffee. I do not have a very exciting hobby, but these things help me switch off after studying. If I have a longer break, I like taking a bus to a town nearby.
  TXT
  "Did you have the same hobbies when you were a child?" => <<~TXT.strip,
    Not really. As a child I spent most of my free time outside, playing football in the lane or flying a kite. I also collected stickers, which seems very small now. I still like being outdoors, but I read and cook much more than I used to. So the interest in simple, quiet activities is new.
  TXT
  "How often do you use your phone each day, and what for?" => <<~TXT.strip,
    I use my phone many times a day, probably more than I should. I check messages, look at maps, and listen to music on the way to class. I also use it to read the news in the evening. I try not to keep it on the table while I am studying, because I lose concentration very quickly if it lights up.
  TXT
  "What kind of weather do you enjoy most? Why?" => <<~TXT.strip,
    I enjoy cool, dry weather, the kind we get for a few weeks at the start of winter. I can walk without feeling tired, and I sleep better at night. Heavy rain is fine if I am at home, but I do not like going out in it. Very hot days make it hard for me to concentrate, so I am always glad when they end.
  TXT
  "What do you usually eat for breakfast?" => <<~TXT.strip,
    On a normal day I eat bread with egg, or a bowl of noodles if I have time to stop at a stall. I always have tea or coffee. At the weekend I sometimes make something larger, like pancakes, because I do not have to rush. Breakfast is the meal I am least likely to skip.
  TXT
  "Do you prefer eating at home or in a restaurant? Why?" => <<~TXT.strip,
    I prefer eating at home on ordinary days, because I can choose the ingredients and it costs less. Cooking also helps me relax. I like restaurants for special meals, when I want a dish I cannot make well, or when I am meeting friends. So home is for everyday food, and a restaurant is for an occasion.
  TXT
  "What kind of music do you like to listen to?" => <<~TXT.strip,
    I mostly listen to quiet pop and a little jazz when I am studying. If I am cleaning or walking, I choose something faster. I do not follow one singer very closely. What matters to me is the mood: soft music in the evening, and something with a clear beat when I need energy.
  TXT
  "Have you ever learned to play a musical instrument?" => <<~TXT.strip,
    Yes. I learned the guitar for about a year when I was at school. I could play a few simple songs, but I stopped because I did not practise enough. I still have the guitar at my parents' house. I would like to start again, though I know it will feel difficult at first.
  TXT
  "Do you prefer reading books or articles online?" => <<~TXT.strip,
    I prefer books when I want a full story or a subject I will stay with for days. Articles online are better for news and for a quick explanation. The problem with articles is that I often open another one before I finish the first. A book keeps me in one place, so I remember more.
  TXT
  "Did anyone read to you when you were a child?" => <<~TXT.strip,
    Yes, my mother used to read to me before bed when I was small. They were short stories, sometimes the same one many times. I think that is why I still like reading in the evening. After I learned to read alone, she stopped, but I remember those nights clearly.
  TXT
  "How do you usually travel to work or to class?" => <<~TXT.strip,
    I usually go to class by bus. It takes about twenty-five minutes if the traffic is normal. I could ride a motorbike, but the bus is cheaper and I can look at my notes. When it rains very hard I sometimes ask a friend for a lift. I rarely take a taxi.
  TXT
  "Is traffic a problem where you live?" => <<~TXT.strip,
    Yes, especially between seven and eight in the morning. The main road near my house becomes very slow, and the buses stop moving for several minutes. In the middle of the day it is much better. The city has added a few bus lanes, but most people still use motorbikes, so the problem has not gone away.
  TXT
  "What time do you usually get up, and why?" => <<~TXT.strip,
    I usually get up at six. My first class is at seven-thirty, and I like to have breakfast without rushing. If I wake up later I skip the meal and feel hungry by ten. On Sunday I stay in bed until about eight, which feels late to me now.
  TXT
  "Which part of the day do you enjoy most?" => <<~TXT.strip,
    I enjoy the early evening most, after I have finished class and before it is fully dark. The streets are busy but not stressful, and the heat has dropped. I often buy a drink and walk for twenty minutes. Mornings are useful, but I do not enjoy them in the same way.
  TXT
  "How often do you meet your friends?" => <<~TXT.strip,
    I meet my closest friends about once a week, usually on Saturday afternoon. During the week we mostly send messages, because our class times are different. If someone has a birthday we make a larger plan. Once a week is enough for me. I like seeing them properly rather than for ten minutes.
  TXT
  "Do you prefer a large group of friends or a few close ones?" => <<~TXT.strip,
    I prefer a few close friends. In a large group I often listen more than I talk, and I leave feeling tired. With two or three people I can say what I actually think. I am friendly with many classmates, but I would not call all of them close friends.
  TXT
  "Describe a skill that you learned and that has been useful to you." => <<~TXT.strip,
    I would like to describe learning to cook simple meals, which I started when I left home for university.

    I learned it in my first year, mostly from my mother on the phone and from a few videos. At the beginning I could only boil noodles. The difficult part was timing. I often burned garlic or made rice that was too wet. After a month of cooking four evenings a week, I could make a decent meal with vegetables, egg and rice in about half an hour.

    It has been useful in several ways. I spend less money than when I ate out every night, and I eat more vegetables. It also makes the evening feel calmer, because I am doing something with my hands instead of looking at my phone. When friends visit, I can cook for them, which I could not do before. So a small domestic skill has changed my daily life more than I expected.
  TXT
  "Describe a journey you remember well." => <<~TXT.strip,
    A journey I remember well is a night bus I took from my hometown to Da Nang two years ago.

    I went with my cousin. We left at eight in the evening because the tickets were cheaper than the train. For the first hour we talked and shared some fruit. Then the bus climbed into the hills and the road became narrow. Around midnight it started to rain, and the driver slowed down a great deal. I did not sleep much. Near morning we stopped at a small station for noodles, and the sky was just getting light.

    I remember it because it was the first long trip I organised myself, and also because the weather made it feel uncertain. Nothing dangerous happened, but I was relieved when we arrived. Since then I check the forecast before I book a night bus, and I prefer the train if I can get a seat.
  TXT
  "Describe a person who has helped you to achieve a goal." => <<~TXT.strip,
    The person I want to talk about is Ms Lan, an English teacher I had in my last year of school.

    My goal was to pass an English exam well enough to enter the university course I wanted. I was fine at reading, but I froze in speaking. She stayed after class twice a week and made me answer simple questions without reading from a paper. She also showed me how to plan a one-minute answer: one idea, one reason, one example.

    At first I felt embarrassed, because the other students had already gone home. After a few weeks I became less afraid of pauses. I did pass the exam, and I still use her method when I prepare for speaking now. I felt grateful rather than simply proud of the score, because I knew I would not have practised in that way alone.
  TXT
  "Describe a book you enjoyed reading." => <<~TXT.strip,
    A book I enjoyed is a short novel I read last summer, about a young woman who returns to her hometown after several years away.

    I read it in July, mostly in the evenings, and I finished it in about a week. The story follows her as she meets old friends and notices how the town has changed. It is not a very dramatic plot. Most of the interest is in small conversations and in what people do not say.

    I enjoyed it because the places felt familiar, even though the country was different from mine. It also made me think about how I talk to my own family when I go home. I would recommend it to someone who likes quiet books rather than fast stories.
  TXT
  "Describe a place in your city that you like to visit." => <<~TXT.strip,
    The place I like to visit is the lake in the centre of my city.

    It is about fifteen minutes from my house by bus. I go there once or twice a week, usually late in the afternoon. I walk around the path, sometimes buy a drink from a stall, and sit on a bench if I can find one. At the weekend there are more families, and children ride bicycles on the inner path.

    I like it because it is one of the few places where I can be outside without having an errand. The water and the trees make the traffic feel further away. If I have a problem with an essay, a walk there often helps me see the next step. It is ordinary, but it is the part of the city I would show a visitor first.
  TXT
  "Describe a piece of technology you find useful." => <<~TXT.strip,
    A piece of technology I find useful is a small laptop I bought two years ago.

    I got it at the start of university, with money I had saved from a summer job. I use it every day for writing essays, joining online classes, and storing my notes. It is not a powerful machine, so I do not play games on it. The battery lasts long enough for a morning at the library, which is what I needed.

    It is useful because almost all of my course work lives on it, and I can carry it more easily than a stack of books. When it once failed for a day, I realised how much I depend on it. I now keep a copy of important files online. Even so, I would not want to go back to doing all my writing on my phone.
  TXT
  "Describe a cafe that you like to go to." => <<~TXT.strip,
    I like a small cafe on a side street near the university.

    It is on the ground floor of an old house, about five minutes from the campus gate. I go there once a week, usually on Thursday after my last class. I order coffee with milk and, if I am hungry, a piece of cake. The tables are close together, but it is rarely loud, so I can read for an hour.

    I like it because the staff know my order and do not rush me. It is also a neutral place to meet a friend when our homes are in different parts of the city. Bigger cafes nearby are brighter, but this one feels calmer. I have done some of my best revision there.
  TXT
  "Describe a teacher who has influenced you." => <<~TXT.strip,
    A teacher who influenced me is Mr Khoa, who taught history when I was fifteen.

    He was strict about homework, but he did not teach by asking us to copy the board. He would put a short source on the screen, a letter or a photo, and ask what we could actually know from it. At first I found this slow. I wanted the correct answer immediately.

    What changed me was a comment he wrote on an essay: he said my facts were fine, but I had not explained why they mattered. After that I started adding a sentence of reason, not only in history but in other subjects. I feel grateful now. I still write in that way, and I think of him when I am tempted to list points without a point of view.
  TXT
  "Describe an important decision you have made." => <<~TXT.strip,
    An important decision I made was to study in this city rather than stay in my hometown.

    I decided in the spring before university, about three years ago. I considered the cost, the course, and how often I could visit my parents. The hometown university was cheaper and closer, and my family would have preferred that. The course here had a stronger business department and a year that includes a short placement.

    It was important because it set the shape of my week and my friendships. The first months were lonely, and I sometimes thought I had chosen badly. Now I am glad I came. I have learned to live alone, and the course is what I wanted. The decision still costs money, but it was the right one for the work I hope to do.
  TXT
  "Describe a gift you received that was meaningful." => <<~TXT.strip,
    A meaningful gift I received was a fountain pen from my grandfather.

    He gave it to me when I finished school, at a family lunch. It is a simple black pen, not an expensive one, but he had used the same kind for years in his job as a clerk. He said I should have something to write with that was not a phone.

    It was meaningful because he rarely bought gifts, and because it came with advice I still remember: write slowly if the decision is important. I use the pen for notes I want to keep, not for shopping lists. When he died last year, the pen became a way of thinking about him. I am careful not to lose it.
  TXT
  "Describe a day when you were very busy." => <<~TXT.strip,
    A very busy day for me was the Friday before last, when I had a presentation and a family visit on the same day.

    I had to give a ten-minute talk in the morning, then meet my parents at the bus station at two, and finish a short report by evening. I managed the time by preparing the slides the night before and writing the report in outline form during lunch. I also told my parents I might be fifteen minutes late, so they would not worry.

    At the end of the day I felt tired but satisfied. The presentation went well enough, and dinner with my parents was the part I had been looking forward to. I would not want every day to be like that. It showed me that a written plan, even a rough one, stops me from forgetting the thing that matters.
  TXT
  "Describe a website you use often." => <<~TXT.strip,
    A website I use often is an online dictionary that also shows example sentences.

    I found it in my first month at university, when a teacher recommended it. I use it several times a day while I read. I look up a word, check the pronunciation, and read two or three examples so I can see the grammar around it. I also keep a list, inside the site, of words I want to review.

    I use it often because it is faster than a paper dictionary and clearer than a quick translation. The examples stop me from learning a word with the wrong meaning. I still make mistakes, but I make fewer of the kind where I know a word and cannot use it. For that reason it has become part of how I study English.
  TXT
  "Do you think practical skills are more important than academic knowledge for young people today?" => <<~TXT.strip,
    I think young people need both, but practical skills have become easier to ignore at school, so they deserve more attention.

    Academic knowledge still matters. A nurse or an engineer has to understand theory, or the practical work becomes dangerous. Reading and writing also help people learn a new skill later, when the tools have changed.

    At the same time, many students leave school unable to cook, budget, or speak clearly in a meeting. Those are not small gaps. Employers often say they can teach the software, but they cannot quickly teach someone to organise their time. So I would not rank one above the other. I would give practical skills a proper place in the timetable, next to academic subjects, rather than treating them as hobbies.
  TXT
  "How has technology changed the way people learn new skills?" => <<~TXT.strip,
    Technology has made the start of learning much easier, and the middle of learning more confusing.

    Someone who wants to cook, code, or play the guitar can watch a free lesson in the evening. They can also repeat a short clip, which a live class does not allow. People in small towns now reach teachers they would never have met.

    The difficulty is choosing. There are hundreds of lessons, and many of them disagree. Without a person to correct you, it is easy to practise a mistake. I think technology is excellent for information and for practice material, but a skill that involves judgement still improves faster with feedback from someone experienced.
  TXT
  "Why do you think some people prefer to travel alone?" => <<~TXT.strip,
    Some people prefer to travel alone because they want control of the day, and because they like the feeling of managing a place by themselves.

    In a group, every meal and every museum becomes a discussion. A person travelling alone can change the plan when they are tired, or stay longer in a town they did not expect to like. They also speak to local people more often, because they cannot hide inside a group of friends.

    It is not only independence. Some travellers find that they notice more when they are quiet. Of course it can be lonely, and it is less safe in certain places. People who choose it are usually willing to accept that in exchange for freedom.
  TXT
  "What effects can tourism have on the environment?" => <<~TXT.strip,
    Tourism can protect a place or wear it down, depending on the numbers and the rules.

    On the positive side, ticket money can pay for paths, wildlife staff and the repair of old buildings. If visitors pay to see a forest, the community has a reason to keep it. Hotels can also employ people who might otherwise cut trees or fish beyond the limit.

    The damage is easy to see in popular spots. Coaches and flights add pollution, hotels use a lot of water, and paths erode when too many people walk them. Rubbish is a problem where bins and rules are weak. I think the useful step is to limit daily numbers in fragile places and to spend the fees on the site itself, not only on advertising.
  TXT
  "Should people rely more on family or on professionals when they need advice?" => <<~TXT.strip,
    It depends on the kind of advice. I would ask family about personal choices, and a professional about technical ones.

    Family members know your history. If you are deciding whether to move city or how to handle a difficult relative, they may see things a stranger would miss. They also care about the result in a way a paid adviser might not. The risk is that they give the answer they want, not the one you need.

    For health, law or money, a professional has training and has seen many similar cases. A parent can comfort you, but they should not replace a doctor. The best pattern, in my view, is to hear both: the professional for the facts, and the family for how those facts fit your life.
  TXT
  "Do you think people are less willing to help strangers than in the past?" => <<~TXT.strip,
    I am not sure the willingness has fallen. I think the situations have become less personal, so help looks different.

    In a small neighbourhood, people knew who needed help and they helped face to face. In a city, we pass hundreds of strangers and we cannot respond to all of them. Some people also worry about being cheated, which makes them hesitate.

    At the same time, many people give money online after a flood, or donate blood, which did not exist in the same way before. So the habit of helping may have moved rather than disappeared. What has declined, perhaps, is the small daily help: holding a door, giving directions, or asking if someone is all right.
  TXT
  "Why do some people prefer films to books?" => <<~TXT.strip,
    Some people prefer films because they take less time and because pictures and sound do part of the work.

    A novel may need ten hours. A film tells a version of the story in two. After a long day, that difference matters. Films also show a face, a street or a piece of music directly, so the viewer does not have to imagine everything. For people who find long texts tiring, a film is simply more accessible.

    I still think books go further into a character's thoughts. People who prefer films are not always avoiding thought. They may want a shared experience, since it is easier to watch a film with someone than to read together. Both forms are valuable. They suit different evenings.
  TXT
  "Should schools spend more time on reading? Why?" => <<~TXT.strip,
    Yes, I think most schools should spend more time on reading, especially on reading that is slower than a screen.

    Students already practise short messages all day. What they get less of is staying with a difficult page, noticing an argument, and writing a response. Those habits support every other subject. A pupil who can read a science text carefully will learn the science more easily.

    I would not fill the day with novels only. Some of the time should be for news, instructions and graphs, because adult life uses those. The aim is stamina and attention, not a love of one kind of book. If schools cut reading to make room for more tests, they remove the skill the tests are supposed to measure.
  TXT
  "What makes a city a pleasant place to live?" => <<~TXT.strip,
    A pleasant city is one where ordinary days are easy, not one that looks impressive in a photo.

    People need safe streets, reliable buses, and shops for daily food within a short walk. Parks matter because flats are small and children need space that is not a car park. Clean air and a limit on noise make a bigger difference than a famous tower.

    Work is part of it too. If most jobs are an hour away, the city may be beautiful and still feel hard. I would also add a mix of ages and incomes in each district. A place that only the rich can live in is pleasant for a weekend and lonely as a home. So comfort, in my view, is about daily distances and public space.
  TXT
  "How can cities protect green spaces as they grow?" => <<~TXT.strip,
    Cities can protect green spaces by deciding the limits before the buildings arrive, and by treating parks as infrastructure rather than leftover land.

    The practical tools are well known. A city can ban building in certain corridors, require a park in each new housing area, and plant trees along streets so green space is not only one large garden far from home. Roofs and schoolyards can add smaller patches where land is expensive.

    Rules fail if they are changed every time a developer offers money. I think the land should be listed, with a public process before any sale. Cities that did this early still have rivers and parks. Cities that waited often have to buy the land back at a much higher price. Protecting green space is cheaper at the beginning.
  TXT
  "Do people rely too much on smartphones?" => <<~TXT.strip,
    Many people rely on smartphones for things that truly need them, and also for things that do not. The second habit is the problem.

    Maps, payments, messages from school, and a call in an emergency are reasonable uses. It would be strange to call that too much. The excess is the constant checking: news, photos, short videos, often while walking or during a meal. Sleep and conversation suffer, and some people feel anxious when the battery is low, which shows the reliance has become emotional.

    I do not think the answer is to throw the phone away. It is to keep a few tasks on it and to leave it in another room for an hour a day. People who try that usually notice how often they were reaching for it without a reason.
  TXT
  "Will new technology reduce the need for some jobs?" => <<~TXT.strip,
    Yes. New technology has always reduced some jobs, and the current tools will do the same, especially for routine office work.

    Tasks that follow a clear pattern, such as basic translation, simple accounts, or sorting forms, can already be done faster by software. Companies will hire fewer people for those tasks. That does not mean there will be no work. Someone has to check the results, handle unusual cases, and speak to customers when the machine is wrong.

    The difficult part is the gap in time. A job can disappear in a year, while learning a new one takes longer. Societies that train adults while they are still employed will manage this better than societies that wait until people are out of work. So the technology will remove tasks. Whether it removes people's livelihoods depends on the training around it.
  TXT
}.freeze

data = JSON.parse(File.read(PATH))
missing = []
data["prompts"].each do |prompt|
  answer = ANSWERS[prompt["question"]]
  if answer.nil? || answer.empty?
    missing << prompt["question"]
    next
  end
  prompt["sampleAnswer"] = answer
end
extra = ANSWERS.keys - data["prompts"].map { |prompt| prompt["question"] }
raise "missing #{missing.inspect}" unless missing.empty?
raise "extra #{extra.inspect}" unless extra.empty?

File.write(PATH, JSON.pretty_generate(data) + "\n")
puts "prompts=#{data["prompts"].size} with_sample=#{data["prompts"].count { |p| p["sampleAnswer"].to_s.length > 80 }}"
