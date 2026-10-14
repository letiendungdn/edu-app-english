require "json"

path = "/Users/dung/Projects/edu-app-english/backend/src/main/resources/content/grammar.json"
data = JSON.parse(File.read(path))
known = data["topics"].map { |topic| topic["title"] }

def topic(title, description, level, sort_order, lesson_title, explanation, examples, exercises)
  raise "description #{title}" if description.length > 240
  examples.each { |en| raise "example #{title}" if en.length > 240 }
  exercises.each do |question, answer, options|
    raise "answer missing #{title}: #{answer}" unless options.include?(answer)
    raise "long #{title}" if [question, answer, *options].any? { |field| field.length > 240 }
  end
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
  topic("Have something done", "have / get + tân ngữ + V3 — nhờ người khác làm", "C1", 30,
    "Nhờ hoặc để người khác làm việc đó cho mình",
    "have / get + tân ngữ + past participle nghĩa là mình thu xếp để người khác làm việc đó.\n\n• I had my laptop repaired.\n• She got her hair cut yesterday.\n• We need to have the windows cleaned.\n\nKhông dùng V-ing ở đây. So sánh: I repaired my laptop (tự làm) và I had my laptop repaired (thợ làm).",
    ["I had my bike repaired yesterday.", "She is getting her hair cut."],
    [
      ["I ___ my watch repaired last week.", "had", ["had", "have", "was", "did"]],
      ["She got her hair ___.", "cut", ["cut", "cutting", "to cut", "cuts"]],
      ["We need to have the windows ___.", "cleaned", ["cleaned", "cleaning", "clean", "to clean"]]
    ]),
  topic("Non-defining relative clauses", "Mệnh đề quan hệ bổ sung, có dấu phẩy", "C1", 31,
    "who / which thêm thông tin, không xác định danh từ",
    "Mệnh đề không xác định thêm thông tin phụ. Có dấu phẩy, và bỏ đi câu vẫn đủ nghĩa.\n\n• My sister, who lives in Hue, is a doctor.\n• The report, which was finished late, has several errors.\n\nKhông dùng that. Không lược bỏ who / which.",
    ["My sister, who lives in Hue, is a doctor.", "The old bridge, which was built in 1920, is still used."],
    [
      ["My uncle, ___ lives in Da Nang, is visiting us.", "who", ["who", "which", "that", "whose"]],
      ["The report, ___ was sent yesterday, is too long.", "which", ["which", "who", "what", "whose"]],
      ["Không dùng ___ trong mệnh đề không xác định.", "that", ["that", "who", "which", "whose"]]
    ]),
  topic("Unless and provided that", "Điều kiện phủ định và điều kiện bắt buộc", "C1", 32,
    "unless = if not; provided that = chỉ khi",
    "unless thay cho if ... not: Unless you book early, the course will be full.\nprovided that / as long as đưa điều kiện phải có: You can borrow the car provided that you return it tonight.\n\nunless không đi với will trong mệnh đề của nó: Unless it rains, we will walk.",
    ["Unless you leave now, you will miss the train.", "You can go out provided that you finish your homework."],
    [
      ["___ you hurry, you will miss the bus.", "Unless", ["Unless", "Provided", "Although", "Despite"]],
      ["You may leave early ___ that the report is finished.", "provided", ["provided", "unless", "although", "despite"]],
      ["Unless it ___, we will have the picnic.", "rains", ["rains", "will rain", "rained", "is raining will"]]
    ]),
  topic("Be supposed to", "be supposed to — được cho là, lẽ ra phải", "C1", 33,
    "Nghĩa vụ hoặc điều người khác trông đợi",
    "be supposed to + V nói việc ai đó được kỳ vọng phải làm, hoặc điều người ta tin.\n\n• You are supposed to wear a helmet.\n• The meeting was supposed to start at nine.\n• It is supposed to be a quiet area.\n\nQuá khứ was supposed to thường có nghĩa việc đó đã không xảy ra như kỳ vọng.",
    ["Students are supposed to hand in the essay on Friday.", "The train was supposed to arrive at six."],
    [
      ["You ___ supposed to switch off your phone.", "are", ["are", "have", "do", "be"]],
      ["The film was supposed to ___ at eight.", "start", ["start", "starting", "started", "starts"]],
      ["It is supposed ___ a very good book.", "to be", ["to be", "be", "being", "been"]]
    ]),
  topic("In order to and so as to", "Mục đích với to, in order to, so as to", "C1", 34,
    "Nói lý do mình làm một việc",
    "in order to / so as to + V nói mục đích. to + V cũng được và ngắn hơn.\n\n• She left early in order to catch the bus.\n• He spoke quietly so as not to wake the baby.\n\nPhủ định là in order not to / so as not to, không phải so as to not.",
    ["She studies at night in order to pass the exam.", "He whispered so as not to wake the baby."],
    [
      ["I came early ___ to get a good seat.", "in order", ["in order", "in case", "so that", "because"]],
      ["She walked quietly so as ___ to wake anyone.", "not", ["not", "no", "don't", "never"]],
      ["He took a taxi in order ___ the train.", "to catch", ["to catch", "catching", "catch", "for catch"]]
    ]),
  topic("Shouldn't have", "should have / shouldn't have — đáng lẽ", "C1", 35,
    "Nhìn lại việc đã xảy ra",
    "should have + V3 nói việc đáng lẽ đã làm. shouldn't have + V3 nói việc đáng lẽ không làm.\n\n• I should have left earlier.\n• You shouldn't have said that.\n\nĐây là nhận xét về quá khứ, không phải nghĩa vụ ở hiện tại (should + V).",
    ["I should have checked the address.", "You shouldn't have left the door open."],
    [
      ["I should ___ called you yesterday.", "have", ["have", "has", "had", "of"]],
      ["You shouldn't have ___ so late.", "stayed", ["stayed", "stay", "staying", "to stay"]],
      ["She should have ___ the form.", "signed", ["signed", "sign", "signing", "to sign"]]
    ]),
  topic("The more the more", "So sánh kép: the + so sánh ... the + so sánh", "C2", 20,
    "Hai vế thay đổi cùng nhau",
    "the + comparative, the + comparative nói hai điều tăng hoặc giảm cùng lúc.\n\n• The harder you practise, the better you get.\n• The more I read, the more I enjoy it.\n\nTính từ ngắn thêm -er. Tính từ dài dùng more. Không dùng more more.",
    ["The earlier we leave, the less traffic we meet.", "The more carefully you check, the fewer mistakes you make."],
    [
      ["The ___ you practise, the better you become.", "more", ["more", "most", "much", "many"]],
      ["The harder she worked, ___ tired she felt.", "the more", ["the more", "more", "the most", "very"]],
      ["The sooner we start, the ___ we will finish.", "earlier", ["earlier", "earliest", "more early", "early"]]
    ]),
  topic("It is said that", "Cấu trúc tường thuật vô nhân xưng", "C2", 21,
    "it is said that / he is said to",
    "Khi không cần nêu ai nói, dùng it is said / believed / reported that ...\nHoặc đưa người lên trước: He is said to be very strict.\n\n• It is believed that the plan will change.\n• She is reported to have left the company.\n\nhave + V3 khi việc đã xảy ra: is said to have resigned.",
    ["It is said that the museum will close.", "The minister is reported to have resigned."],
    [
      ["It is ___ that the bridge is unsafe.", "said", ["said", "say", "saying", "says"]],
      ["He is believed ___ abroad.", "to live", ["to live", "live", "living", "lives"]],
      ["She is said to ___ the prize last year.", "have won", ["have won", "win", "won", "winning"]]
    ]),
  topic("It's time and if only", "Ước và việc đáng lẽ đã xảy ra", "C2", 22,
    "it's time / if only + quá khứ đơn hoặc quá khứ hoàn thành",
    "It's time + quá khứ đơn nói việc đáng lẽ phải làm rồi: It's time we left.\nIf only + quá khứ đơn ước hiện tại: If only I knew.\nIf only + past perfect ước quá khứ: If only I had checked.\n\nĐộng từ ở quá khứ nhưng nghĩa là hiện tại hoặc quá khứ, không phải một sự thật đã xảy ra.",
    ["It's time we went home.", "If only I had saved the file."],
    [
      ["It's time we ___.", "left", ["left", "leave", "are leaving", "will leave"]],
      ["If only I ___ the answer.", "knew", ["knew", "know", "have known", "am knowing"]],
      ["If only she ___ earlier.", "had called", ["had called", "called", "has called", "calls"]]
    ]),
  topic("Comment adverbs", "Trạng từ nêu thái độ người nói", "C2", 23,
    "apparently, admittedly, presumably đứng tách khỏi động từ",
    "Comment adverbs nói thái độ của người viết, thường đứng đầu câu và có dấu phẩy.\n\n• Apparently, the meeting has been cancelled.\n• Admittedly, the first draft was weak.\n• Presumably, they will write back this week.\n\nChúng không bổ nghĩa cho động từ theo cách trạng từ cách thức (carefully, slowly).",
    ["Apparently, the shop is closed on Mondays.", "Admittedly, the test was harder than I expected."],
    [
      ["___, nobody told us about the change.", "Apparently", ["Apparently", "Carefully", "Quickly", "Loudly"]],
      ["___, the plan has some risks.", "Admittedly", ["Admittedly", "Softly", "Nearly", "Early"]],
      ["___, the letter will arrive tomorrow.", "Presumably", ["Presumably", "Suddenly", "Hardly", "Directly"]]
    ]),
  topic("I think so", "so và not thay cho cả mệnh đề", "C2", 24,
    "think so, hope not, I'm afraid so",
    "so thay một mệnh đề khẳng định vừa nói. not thay mệnh đề phủ định.\n\n• Will it rain? I think so. / I hope not.\n• Is the shop open? I'm afraid not.\n\nDùng được với think, hope, believe, expect, be afraid, suppose. Không nói I think yes.",
    ["Will they come? I think so.", "Has the train left? I hope not."],
    [
      ["Is the cafe open? I think ___.", "so", ["so", "yes", "it", "that"]],
      ["Will it rain? I hope ___.", "not", ["not", "no", "none", "don't"]],
      ["Did she pass? I'm afraid ___.", "not", ["not", "no", "so not", "none"]]
    ]),
  topic("Apposition", "Danh từ đứng cạnh danh từ để giải thích", "C2", 25,
    "Hai cụm danh từ chỉ cùng một người hoặc vật",
    "Apposition đặt một cụm danh từ ngay sau cụm khác để gọi tên hoặc giải thích.\n\n• Ms Lan, the course tutor, will meet you at noon.\n• We visited Hue, a city in central Vietnam.\n\nCụm giải thích thường có dấu phẩy nếu là thông tin phụ.",
    ["Mr Khan, the new manager, starts on Monday.", "We stayed in Hoi An, a town on the central coast."],
    [
      ["Ms Hoa, ___ course tutor, is away today.", "the", ["the", "who", "which", "whose"]],
      ["We visited Hue, ___ city in central Vietnam.", "a", ["a", "which", "that", "whose"]],
      ["My friend Nam, ___ engineer, designed the bridge.", "an", ["an", "who", "which", "whose"]]
    ])
]

added = 0
topics.each do |item|
  if known.include?(item["title"])
    next
  end
  data["topics"] << item
  known << item["title"]
  added += 1
end

File.write(path, JSON.pretty_generate(data) + "\n")
puts "grammar_added=#{added} topics=#{data["topics"].size}"
