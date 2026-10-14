require "json"

path = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content/grammar.json"
data = JSON.parse(File.read(path))
known = data["topics"].map { |topic| topic["title"] }

def topic(title, description, level, sort_order, lesson_title, explanation, examples, exercises)
  {
    "title" => title,
    "description" => description,
    "level" => level,
    "sortOrder" => sort_order,
    "lessons" => [
      {
        "title" => lesson_title,
        "level" => level,
        "sortOrder" => 1,
        "explanation" => explanation,
        "examples" => examples.each_with_index.map { |en, i| { "en" => en, "sortOrder" => i + 1 } },
        "exercises" => exercises.each_with_index.map { |item, i|
          question, answer, options = item
          { "question" => question, "answer" => answer, "sortOrder" => i + 1, "options" => options }
        }
      }
    ]
  }
end

topics = [
  topic("Adverbs of frequency", "always, usually, often, sometimes, never", "A1", 40,
    "Trạng từ tần suất đứng trước động từ thường",
    "always, usually, often, sometimes, never nói việc xảy ra thường xuyên thế nào.\nĐứng trước động từ thường: I usually walk to school.\nĐứng sau to be: She is always late.\nCâu hỏi: How often do you exercise?",
    ["I usually have coffee in the morning.", "He is never late."],
    [
      ["I ___ walk to school. (gần như mọi ngày)", "usually", ["usually", "never", "am usually", "usual"]],
      ["She ___ always tired.", "is", ["is", "does", "has", "be"]],
      ["How ___ do you study English?", "often", ["often", "always", "usually do", "many"]]
    ]),
  topic("Have got", "have got — có, trong tiếng Anh Anh", "A1", 41,
    "have got / has got",
    "have got nghĩa là có, hay gặp trong tiếng Anh Anh.\n• I have got a brother. = I have a brother.\n• She has got two cats.\nPhủ định: I haven't got any money.\nCâu hỏi: Have you got a pen?",
    ["I have got a new phone.", "Has she got any brothers?"],
    [
      ["She ___ got two sisters.", "has", ["has", "have", "is", "does"]],
      ["I ___ got any milk.", "haven't", ["haven't", "hasn't", "don't got", "am not"]],
      ["___ you got a ticket?", "Have", ["Have", "Do", "Are", "Has"]]
    ]),
  topic("Prepositions of place", "in, on, at, under, next to", "A1", 42,
    "Giới từ nơi chốn",
    "in: bên trong. The book is in the bag.\non: trên bề mặt. The keys are on the table.\nat: tại một điểm. She is at the door.\nunder: bên dưới. next to: bên cạnh. behind: phía sau. between: ở giữa hai vật.",
    ["The cat is under the chair.", "We live next to a park."],
    [
      ["The milk is ___ the fridge.", "in", ["in", "on", "at", "under the inside"]],
      ["Your phone is ___ the table.", "on", ["on", "in", "at", "between"]],
      ["She is waiting ___ the bus stop.", "at", ["at", "in", "on", "under"]]
    ]),
  topic("Prepositions of time", "in, on, at với thời gian", "A1", 43,
    "in tháng/năm, on ngày, at giờ",
    "at + giờ: at 7 o'clock, at night.\non + ngày: on Monday, on 5 May.\nin + tháng, năm, buổi: in June, in 2020, in the morning.\nKhông dùng giới từ trước today, tomorrow, every day.",
    ["The class is at 8 o'clock.", "I was born in May."],
    [
      ["The meeting is ___ Monday.", "on", ["on", "in", "at", "by"]],
      ["I get up ___ 6 o'clock.", "at", ["at", "on", "in", "to"]],
      ["We travel ___ the summer.", "in", ["in", "on", "at", "by"]]
    ]),
  topic("Like, love and hate", "like/love/hate + danh từ hoặc V-ing", "A1", 44,
    "Thích hoặc ghét một việc",
    "like, love, hate, enjoy đi với danh từ hoặc động từ thêm -ing.\n• I like coffee.\n• She loves reading.\n• They hate waiting.\nCâu hỏi: Do you like swimming?\nKhông nói: I like swim.",
    ["I enjoy cooking.", "Do you like rainy days?"],
    [
      ["She loves ___.", "reading", ["reading", "read", "to reading", "reads"]],
      ["Do you like ___?", "swimming", ["swimming", "swim", "to swimming", "swims"]],
      ["He hates ___ for the bus.", "waiting", ["waiting", "wait", "to waiting", "waits"]]
    ]),
  topic("Past simple and past continuous", "Việc nền và việc cắt ngang", "A2", 40,
    "was/were + V-ing khi một việc khác xảy ra",
    "Past continuous là việc đang diễn ra. Past simple là việc ngắn cắt ngang.\n• I was cooking when the phone rang.\n• They were walking home when it started to rain.\nwhen + past simple. while + past continuous.",
    ["I was sleeping when you called.", "While she was reading, the lights went out."],
    [
      ["I ___ (cook) when the phone rang.", "was cooking", ["was cooking", "cooked", "am cooking", "were cooking"]],
      ["They ___ (walk) home when it started to rain.", "were walking", ["were walking", "walked", "was walking", "are walking"]],
      ["While she ___ (read), the lights went out.", "was reading", ["was reading", "read", "reads", "is reading"]]
    ]),
  topic("Present continuous for future", "Kế hoạch đã sắp xếp", "A2", 41,
    "be + V-ing cho lịch đã chốt",
    "Dùng hiện tại tiếp diễn cho kế hoạch đã có thời gian hoặc đã sắp xếp.\n• I am meeting Mai at 6.\n• We are flying to Da Nang tomorrow.\nwill dùng khi quyết định lúc nói. going to dùng cho dự định.",
    ["I am seeing the dentist on Friday.", "They are leaving tonight."],
    [
      ["I ___ (meet) Lan at 6. We agreed yesterday.", "am meeting", ["am meeting", "meet", "will meeting", "meeting"]],
      ["We ___ (fly) to Hue tomorrow. The tickets are booked.", "are flying", ["are flying", "fly", "are fly", "flying"]],
      ["She ___ (not/work) next Monday.", "isn't working", ["isn't working", "doesn't work", "isn't work", "not working"]]
    ]),
  topic("Comparisons with as", "as + tính từ + as", "A2", 42,
    "Bằng nhau và không bằng nhau",
    "as + tính từ + as: bằng nhau.\n• This room is as big as that one.\nnot as + tính từ + as: không bằng.\n• The bus is not as fast as the train.\nCó thể thay not as bằng not so: not so cheap as.",
    ["Mai is as tall as her sister.", "This bag is not as heavy as that one."],
    [
      ["This room is ___ big as that one.", "as", ["as", "so", "than", "more"]],
      ["The bus is not ___ fast as the train.", "as", ["as", "than", "more", "so than"]],
      ["He is ___ old as me. (bằng tuổi)", "as", ["as", "more", "the", "so old"]]
    ]),
  topic("Indefinite pronouns", "something, anything, nothing, everyone", "A2", 43,
    "some-, any-, no-, every-",
    "Câu khẳng định: something, someone, somewhere.\nCâu phủ định và câu hỏi: anything, anyone, anywhere.\n• There is someone at the door.\n• I don't know anything.\nnothing / no one đã mang nghĩa phủ định, không thêm not.\n• Nothing happened.",
    ["Is there anything in the fridge?", "Everyone is here."],
    [
      ["There is ___ at the door.", "someone", ["someone", "anyone", "no one not", "something person"]],
      ["I don't know ___.", "anything", ["anything", "something", "nothing", "everything not"]],
      ["___ happened. The room was quiet.", "Nothing", ["Nothing", "Anything", "Not nothing", "Something not"]]
    ]),
  topic("Reflexive pronouns", "myself, yourself, himself, themselves", "A2", 44,
    "Tự mình làm",
    "myself, yourself, himself, herself, itself, ourselves, yourselves, themselves.\nDùng khi chủ ngữ và tân ngữ là một.\n• She taught herself.\n• I cut myself.\nby + đại từ phản thân = một mình: He lives by himself.",
    ["Be careful. Don't hurt yourself.", "They built the shed themselves."],
    [
      ["She taught ___.", "herself", ["herself", "her", "she", "hers"]],
      ["I cut ___.", "myself", ["myself", "me", "my", "mine"]],
      ["He lives by ___.", "himself", ["himself", "him", "his", "he"]]
    ]),
  topic("So and neither", "Đồng ý với câu vừa nói", "A2", 45,
    "So do I và Neither do I",
    "So + trợ động từ + chủ ngữ: đồng ý với câu khẳng định.\n• I like tea. So do I.\n• She can swim. So can he.\nNeither + trợ động từ + chủ ngữ: đồng ý với câu phủ định.\n• I don't smoke. Neither do I.\nTrợ động từ phải khớp thì của câu trước.",
    ["A: I am tired. B: So am I.", "A: He can't drive. B: Neither can I."],
    [
      ["I like tea. So ___ I.", "do", ["do", "am", "have", "did"]],
      ["She can swim. So ___ he.", "can", ["can", "does", "is", "can he do"]],
      ["I don't smoke. Neither ___ I.", "do", ["do", "am", "don't", "so"]]
    ]),
  topic("Although and however", "Nhượng bộ và tương phản", "B1", 40,
    "although nối hai mệnh đề, however nối hai câu",
    "although / even though + mệnh đề, cùng một câu.\n• Although it was raining, we went out.\nhowever đứng đầu câu sau, có dấu phẩy.\n• It was raining. However, we went out.\nKhông viết Although ..., but ...",
    ["Although she was tired, she finished the essay.", "The train was late. However, we arrived on time."],
    [
      ["___ it was cold, they swam.", "Although", ["Although", "However", "But", "Despite of"]],
      ["It was cold. ___, they swam.", "However", ["However", "Although", "Despite", "Even"]],
      ["Although he was late, ___ he apologised.", "—", ["—", "but", "however", "so"]]
    ]),
  topic("Be used to and get used to", "Quen với một việc", "B1", 41,
    "used to khác be used to",
    "used to + động từ: thói quen quá khứ, nay không còn. I used to live in Hue.\nbe used to + danh từ / V-ing: đã quen. I am used to getting up early.\nget used to: đang tập quen. She is getting used to the noise.",
    ["I am used to spicy food.", "He is getting used to driving on the left."],
    [
      ["I am used to ___ (get) up early.", "getting", ["getting", "get", "got", "to getting"]],
      ["She ___ live in Hue, but she moved.", "used to", ["used to", "is used to", "uses to", "was use to"]],
      ["He is getting used to ___ (drive) here.", "driving", ["driving", "drive", "drove", "to drive"]]
    ]),
  topic("Purpose", "so that và in order to", "B1", 42,
    "Nói mục đích",
    "in order to / to + động từ: mục đích của cùng một người.\n• She left early to catch the train.\nso that + mệnh đề, có thể đổi chủ ngữ.\n• She spoke slowly so that everyone could understand.\nso that thường đi với can, could, will, would.",
    ["I set an alarm so that I would not oversleep.", "He studies English in order to work abroad."],
    [
      ["She left early ___ catch the bus.", "to", ["to", "for", "so that", "for to"]],
      ["She spoke slowly so that we ___ understand.", "could", ["could", "can to", "to", "for"]],
      ["He saved money ___ to buy a bike.", "in order", ["in order", "so that", "for", "because"]]
    ]),
  topic("Each and every", "each và every", "B1", 43,
    "Từng cái một",
    "every và each đi với danh từ số ít.\n• Every student has a book.\n• Each answer is different.\neach nhấn từng người trong một nhóm nhỏ. every nhấn tất cả.\neach of + số nhiều: Each of the students has a locker.\nevery không đi với of theo cách Each of.",
    ["Every room has a window.", "Each of the boys was given a map."],
    [
      ["Every student ___ a locker.", "has", ["has", "have", "are", "have got plural"]],
      ["Each of the answers ___ correct.", "is", ["is", "are", "were", "have"]],
      ["___ child was given a ticket. (từng đứa)", "Each", ["Each", "Every of", "All", "Each of every"]]
    ]),
  topic("Gerund or infinitive", "stop, remember, regret đổi nghĩa", "B2", 40,
    "V-ing và to + động từ không cùng nghĩa",
    "remember / forget / regret + V-ing: việc đã xảy ra.\n• I remember locking the door.\nremember / forget + to + động từ: việc cần làm.\n• Remember to lock the door.\nstop + V-ing: ngừng việc đó. stop + to + động từ: dừng lại để làm việc khác.\n• She stopped to buy coffee.",
    ["I regret telling him the secret.", "He stopped smoking last year."],
    [
      ["Remember ___ (lock) the door when you leave.", "to lock", ["to lock", "locking", "lock", "locked"]],
      ["I remember ___ (lock) the door. I did it.", "locking", ["locking", "to lock", "lock", "locked"]],
      ["She stopped ___ (smoke) last year.", "smoking", ["smoking", "to smoke", "smoke", "to smoking"]]
    ]),
  topic("Future in the past", "was going to và would", "B2", 41,
    "Kế hoạch nhìn từ một điểm trong quá khứ",
    "was/were going to: dự định trong quá khứ, thường không xảy ra.\n• I was going to call you, but I lost my phone.\nwould: việc tương lai được thấy từ quá khứ, hay gặp trong tường thuật.\n• She said she would arrive at six.",
    ["We were going to eat out, but the restaurant was closed.", "He promised he would help."],
    [
      ["I ___ going to call you, but my phone died.", "was", ["was", "am", "would", "did"]],
      ["She said she ___ arrive at six.", "would", ["would", "will", "is going", "would to"]],
      ["They ___ going to move, but they changed their minds.", "were", ["were", "are", "would", "was"]]
    ]),
  topic("Relative clauses with prepositions", "the person who I spoke to", "B2", 42,
    "Giới từ cuối mệnh đề hoặc trước whom/which",
    "Văn nói: giới từ đứng cuối.\n• The person who I spoke to was kind.\nVăn viết trang trọng: giới từ đứng trước whom/which.\n• The person to whom I spoke was kind.\n• The topic about which we argued is still open.\nKhông dùng who sau giới từ. Dùng whom hoặc which.",
    ["This is the book that I told you about.", "The city in which she grew up is quiet."],
    [
      ["The person ___ I spoke was the manager. (trang trọng)", "to whom", ["to whom", "who to", "to who", "whom to"]],
      ["The book ___ I told you is sold out. (nói)", "that ... about", ["that ... about", "about which that", "who about", "to which"]],
      ["The city ___ which she was born is small.", "in", ["in", "on", "at", "to"]]
    ]),
  topic("Reference words", "this, such, the former liên kết câu", "C1", 10,
    "Trỏ lại ý vừa nói",
    "this / that có thể trỏ cả một ý, không chỉ một danh từ.\n• Prices rose. This surprised investors.\nsuch + danh từ tóm tắt loại vừa nói: such a delay.\nthe former / the latter trỏ hai danh từ vừa nêu, theo thứ tự trước và sau.\n• Tea and coffee arrived. The latter was cold.",
    ["The train was cancelled. This caused a long queue.", "Oil and gas were discussed. The former is still cheaper."],
    [
      ["Sales fell. ___ worried the board. (việc doanh số giảm)", "This", ["This", "These", "Them", "It them"]],
      ["Tea and coffee were served. ___ was cold. (coffee)", "The latter", ["The latter", "The former", "Such", "This ones"]],
      ["We waited two hours. I had never known ___ a delay.", "such", ["such", "so", "this so", "that such"]]
    ]),
  topic("Register", "Văn nói và văn viết trang trọng", "C2", 10,
    "Chọn từ theo hoàn cảnh",
    "Cùng một ý có thể nói thân mật hoặc viết trang trọng.\n• ask for → request. help → assistance. buy → purchase.\n• kids → children. a lot of → a great deal of.\nTrong bài viết IELTS, ưu tiên dạng trung tính đến trang trọng. Trong Speaking Part 1, dạng nói tự nhiên vẫn đúng.",
    ["The committee requested further information.", "Could you ask the manager for help?"],
    [
      ["Văn viết: We ___ further details.", "requested", ["requested", "asked for them kids", "wanna", "got"]],
      ["Văn nói: Can you ___ me a hand?", "give", ["give", "provide assistance of", "request", "purchase"]],
      ["Văn viết: a ___ of time.", "great deal", ["great deal", "lot", "bunch", "ton"]]
    ])
]

errors = []
fresh = []
topics.each do |item|
  next if known.include?(item["title"])
  errors << "mô tả dài: #{item["title"]}" if item["description"].length > 250
  item["lessons"].each do |lesson|
    lesson["examples"].each { |example| errors << "ví dụ dài: #{item["title"]}" if example["en"].length > 250 }
    lesson["exercises"].each do |exercise|
      errors << "câu hỏi dài: #{item["title"]}" if exercise["question"].length > 250
      errors << "đáp án không khớp: #{item["title"]} / #{exercise["answer"]}" unless exercise["options"].include?(exercise["answer"])
    end
  end
  fresh << item
end
if errors.any?
  warn errors.join("\n")
  exit 1
end
data["topics"].concat(fresh)
File.write(path, JSON.pretty_generate(data) + "\n")
puts "grammar_added=#{fresh.size} total=#{data["topics"].size}"
