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
  topic(
    "Must, should and have to",
    "must, should và have to — bắt buộc, lời khuyên",
    "A2", 20,
    "must / should / have to",
    "must nói điều người nói cho là bắt buộc.\n• You must wear a helmet.\n\nhave to nói nghĩa vụ từ bên ngoài (luật, nội quy).\n• I have to start work at eight.\n\nshould là lời khuyên, không bắt buộc.\n• You should sleep more.\n\nPhủ định: mustn't = cấm. don't have to = không cần thiết.",
    ["You must wear a seatbelt.", "I have to finish this today.", "You should drink more water."],
    [
      ["You ___ smoke here. It is forbidden.", "mustn't", ["mustn't", "don't have to", "shouldn't to", "haven't to"]],
      ["I ___ wear a uniform at school. It is the rule.", "have to", ["have to", "should to", "must to", "has to"]],
      ["You look tired. You ___ rest.", "should", ["should", "must to", "have", "shouldn't to"]]
    ]
  ),
  topic(
    "Too and enough",
    "too và enough — quá mức và đủ",
    "A2", 21,
    "too + tính từ và tính từ + enough",
    "too đứng trước tính từ hoặc trạng từ: quá mức, thường là vấn đề.\n• This bag is too heavy.\n• She speaks too fast.\n\nenough đứng sau tính từ hoặc trạng từ: đủ.\n• He is old enough to drive.\n• She doesn't run fast enough.\n\nSau both có thể có to + động từ: too tired to walk, strong enough to lift it.",
    ["This coffee is too hot to drink.", "She is old enough to travel alone."],
    [
      ["This box is ___ heavy to carry.", "too", ["too", "enough", "very enough", "to"]],
      ["He isn't tall ___ to reach the shelf.", "enough", ["enough", "too", "very", "so"]],
      ["I'm ___ tired ___ study tonight.", "too / to", ["too / to", "enough / to", "too / for", "so / for"]]
    ]
  ),
  topic(
    "Possessives",
    "Sở hữu: 's, whose và tính từ sở hữu",
    "A2", 22,
    "'s, whose và my / your / his",
    "Thêm 's sau người hoặc động vật để nói sở hữu.\n• This is Mai's book. The dog's bowl is empty.\nSố nhiều đã có -s thì chỉ thêm dấu phẩy: the students' classroom.\n\nwhose hỏi hoặc nối mệnh đề sở hữu.\n• Whose bag is this?\n• The man whose car broke down is waiting.\n\nTính từ sở hữu đứng trước danh từ: my, your, his, her, its, our, their.",
    ["This is my sister's phone.", "Whose keys are these?"],
    [
      ["This is ___ bag. (của cô ấy)", "her", ["her", "hers", "she", "she's"]],
      ["The woman ___ son is a doctor lives next door.", "whose", ["whose", "who's", "which", "that"]],
      ["The ___ toys are on the floor.", "children's", ["children's", "childrens'", "children", "child's the"]]
    ]
  ),
  topic(
    "Past perfect",
    "Thì quá khứ hoàn thành — việc xảy ra trước một việc khác trong quá khứ",
    "B1", 20,
    "had + past participle",
    "Past perfect diễn tả một việc đã xong trước một mốc hoặc một việc khác trong quá khứ.\n\nCấu trúc: S + had + V3\n• When I arrived, the film had already started.\n• She had left before I called.\n\nViệc xảy ra sau vẫn dùng Past Simple. Không dùng past perfect cho hai việc chỉ đơn giản nối bằng and theo thứ tự thời gian.",
    ["When I arrived, the train had left.", "She had finished dinner before he came home."],
    [
      ["When we arrived, the match ___ (already/start).", "had already started", ["had already started", "already started", "has already started", "was already start"]],
      ["I ___ (never/see) snow before I went to Sapa.", "had never seen", ["had never seen", "never saw", "have never seen", "did never see"]],
      ["She left after she ___ (lock) the door.", "had locked", ["had locked", "has locked", "was locking", "locks"]]
    ]
  ),
  topic(
    "Present perfect continuous",
    "Thì hiện tại hoàn thành tiếp diễn — việc kéo dài đến hiện tại",
    "B1", 21,
    "have / has been + V-ing",
    "Dùng khi một việc bắt đầu trong quá khứ và vẫn đang tiếp diễn, hoặc vừa dừng và còn dấu vết.\n\nCấu trúc: S + have/has been + V-ing\n• I have been waiting for an hour.\n• She has been studying since morning.\n• It has been raining, so the road is wet.\n\nNhấn vào thời lượng và sự tiếp diễn. Present perfect đơn nhấn vào kết quả: I have written three emails.",
    ["I have been learning English for two years.", "She is tired because she has been working all day."],
    [
      ["I ___ (wait) for twenty minutes.", "have been waiting", ["have been waiting", "am waiting", "waited", "have waited been"]],
      ["How long ___ you ___ (live) here?", "have / been living", ["have / been living", "did / live", "are / living", "have / lived been"]],
      ["Her eyes are red. She ___ (cry).", "has been crying", ["has been crying", "cried", "is cry", "has cried been"]]
    ]
  ),
  topic(
    "Future continuous",
    "Thì tương lai tiếp diễn — đang làm gì tại một lúc trong tương lai",
    "B1", 22,
    "will be + V-ing",
    "Future continuous nói một việc sẽ đang diễn ra tại một thời điểm trong tương lai.\n\nCấu trúc: S + will be + V-ing\n• This time tomorrow I will be flying to Hanoi.\n• Don't call at eight. I will be having dinner.\n\nCũng dùng để hỏi lịch một cách lịch sự: Will you be using the car tonight?",
    ["At 9 p.m. I will be studying.", "Will you be working this weekend?"],
    [
      ["This time tomorrow we ___ (sit) on the train.", "will be sitting", ["will be sitting", "will sitting", "are sit", "will have sit"]],
      ["Don't come at six. I ___ (cook).", "will be cooking", ["will be cooking", "will cooking", "cook", "am be cooking"]],
      ["___ you ___ (use) the room at noon?", "Will / be using", ["Will / be using", "Are / be using", "Will / using", "Do / be using"]]
    ]
  ),
  topic(
    "Zero conditional",
    "Câu điều kiện loại 0 — sự thật luôn đúng",
    "B1", 23,
    "If + hiện tại, hiện tại",
    "Zero conditional nói quy luật, sự thật khoa học hoặc thói quen luôn đúng.\n\nCấu trúc: If + S + hiện tại đơn, S + hiện tại đơn\n• If you heat ice, it melts.\n• If I am late, my boss gets angry.\n\nKhác loại 1: loại 1 nói một khả năng trong tương lai (If it rains, I will stay home).",
    ["If you mix red and blue, you get purple.", "If people don't sleep, they feel tired."],
    [
      ["If you ___ (heat) water to 100°C, it ___ (boil).", "heat / boils", ["heat / boils", "will heat / boils", "heat / boil", "heated / boils"]],
      ["If I drink coffee at night, I ___ (not/sleep).", "don't sleep", ["don't sleep", "won't sleep", "didn't sleep", "am not sleep"]],
      ["Plants die if they ___ (not/get) water.", "don't get", ["don't get", "won't get", "didn't get", "not get"]]
    ]
  ),
  topic(
    "Question tags",
    "Đuôi câu hỏi — kiểm tra thông tin",
    "B1", 24,
    "Câu khẳng định + đuôi phủ định",
    "Question tag là phần ngắn cuối câu để kiểm tra hoặc mời đồng ý.\n\nCâu khẳng định dùng đuôi phủ định, và ngược lại.\n• You are tired, aren't you?\n• She doesn't like fish, does she?\n• They left early, didn't they?\n\nVới I am, đuôi là aren't I? Let's dùng shall we?",
    ["It's cold today, isn't it?", "You haven't finished, have you?"],
    [
      ["She can drive, ___?", "can't she", ["can't she", "can she", "doesn't she", "isn't she"]],
      ["They weren't late, ___?", "were they", ["were they", "weren't they", "did they", "didn't they"]],
      ["Let's go, ___?", "shall we", ["shall we", "will we", "don't we", "aren't we"]]
    ]
  ),
  topic(
    "So and such",
    "so và such — nhấn mạnh mức độ",
    "B1", 25,
    "so + tính từ và such + danh từ",
    "so đứng trước tính từ hoặc trạng từ.\n• The film was so boring.\n• She speaks so clearly.\n\nsuch đứng trước cụm danh từ.\n• It was such a boring film.\n• They are such kind people.\n\nCả hai có thể nối kết quả bằng that:\n• It was so hot that we stayed inside.\n• It was such a long day that I fell asleep.",
    ["The test was so difficult that I needed more time.", "It was such a good book that I read it twice."],
    [
      ["It was ___ a cold day that we stayed home.", "such", ["such", "so", "enough", "too"]],
      ["The music was ___ loud that I couldn't think.", "so", ["so", "such", "such a", "enough"]],
      ["They are ___ friendly people.", "such", ["such", "so", "so a", "enough"]]
    ]
  ),
  topic(
    "Modals of deduction",
    "Suy đoán: must, might, can't",
    "B2", 20,
    "must / might / can't + V hoặc have + V3",
    "Khi suy đoán về hiện tại:\n• must = gần như chắc chắn đúng. She must be at work.\n• might / may = có thể. He might be ill.\n• can't = gần như chắc chắn không. That can't be true.\n\nVề quá khứ, thêm have + V3:\n• She must have left early.\n• He might have forgotten.\n• They can't have finished already.",
    ["The lights are off. They must be out.", "He can't have seen the message. He didn't reply."],
    [
      ["She isn't answering. She ___ be in a meeting.", "must", ["must", "can't to", "musts", "should to"]],
      ["I'm not sure. He ___ have missed the bus.", "might", ["might", "must to", "can't to", "shoulds"]],
      ["You ___ have seen Lan. She is abroad.", "can't", ["can't", "must", "might not to", "don't"]]
    ]
  ),
  topic(
    "Reported questions",
    "Câu hỏi tường thuật",
    "B2", 21,
    "ask + mệnh đề, không đảo ngữ",
    "Khi tường thuật câu hỏi, không đảo trợ động từ và bỏ dấu hỏi.\n\nYes/no questions dùng if hoặc whether.\n• \"Are you ready?\" → She asked if I was ready.\n\nWh-questions giữ từ để hỏi.\n• \"Where do you live?\" → He asked where I lived.\n\nLùi thì giống câu tường thuật thường: do/does biến mất, hiện tại thành quá khứ.",
    ["She asked where I worked.", "He asked me if I had finished."],
    [
      ["\"Where do you live?\" → He asked me where I ___.", "lived", ["lived", "did live", "live", "do live"]],
      ["\"Are you tired?\" → She asked if I ___.", "was tired", ["was tired", "am tired", "tired", "did tired"]],
      ["\"What time does it start?\" → He asked what time it ___.", "started", ["started", "did start", "starts", "start"]]
    ]
  ),
  topic(
    "Mixed conditionals",
    "Câu điều kiện hỗn hợp — quá khứ ảnh hưởng đến hiện tại",
    "B2", 22,
    "If + had + V3, would + V",
    "Mixed conditional nối một điều kiện trong quá khứ với kết quả ở hiện tại.\n\nCấu trúc thường gặp: If + S + had + V3, S + would + V\n• If I had studied medicine, I would be a doctor now.\n• If she had left earlier, she would be here now.\n\nLoại 3 thì cả hai vế đều về quá khứ: would have + V3.",
    ["If I had saved more, I would have a car now.", "If he had taken the job, he would live in Hanoi."],
    [
      ["If I ___ (study) harder, I ___ (have) a better job now.", "had studied / would have", ["had studied / would have", "studied / would have", "had studied / would have had", "study / would have"]],
      ["If she hadn't missed the train, she ___ (be) here now.", "would be", ["would be", "would have been", "was", "had been"]],
      ["If we ___ (leave) earlier, we wouldn't be stuck now.", "had left", ["had left", "left", "would leave", "have left"]]
    ]
  ),
  topic(
    "Passive in different tenses",
    "Bị động ở các thì khác nhau",
    "B2", 23,
    "be ở đúng thì + past participle",
    "Bị động luôn là be + V3. Thì nằm ở động từ be.\n• Hiện tại: The room is cleaned every day.\n• Quá khứ: The room was cleaned yesterday.\n• Hiện tại hoàn thành: The room has been cleaned.\n• Tương lai: The room will be cleaned.\n• Khiếm khuyết: The room must be cleaned.\n\nNgười gây hành động, nếu cần, đứng sau by.",
    ["The report has been finished.", "The letters will be sent tomorrow."],
    [
      ["The bridge ___ (build) in 2010.", "was built", ["was built", "is built", "has built", "built"]],
      ["The documents ___ (already/send).", "have already been sent", ["have already been sent", "have already sent", "are already sent", "were already send"]],
      ["The form must ___ (sign) today.", "be signed", ["be signed", "signed", "to sign", "be sign"]]
    ]
  ),
  topic(
    "Participle clauses",
    "Mệnh đề phân từ — rút gọn mệnh đề",
    "C1", 20,
    "V-ing và V3 thay cho mệnh đề",
    "Mệnh đề phân từ rút gọn khi hai vế cùng chủ ngữ.\n\nHiện tại phân từ (V-ing) cho việc cùng lúc hoặc nguyên nhân.\n• Walking home, I saw an old friend. (= While I was walking home)\n• Feeling tired, she went to bed.\n\nQuá khứ phân từ (V3) mang nghĩa bị động.\n• Built in 1990, the bridge is still safe.\n• Written in haste, the email had several mistakes.",
    ["Feeling ill, he left the meeting early.", "Built in 1890, the station is still in use."],
    [
      ["___ (walk) to work, I met my teacher.", "Walking", ["Walking", "Walked", "To walking", "Walk"]],
      ["___ (write) in 1920, the novel is still popular.", "Written", ["Written", "Writing", "Wrote", "To write"]],
      ["Not ___ (know) the answer, she stayed quiet.", "knowing", ["knowing", "known", "knew", "to know"]]
    ]
  ),
  topic(
    "Cleft sentences",
    "Câu chẻ — nhấn vào một thành phần",
    "C1", 21,
    "It is / was ... that ...",
    "Câu chẻ đưa một thông tin ra trước để nhấn mạnh.\n\nIt + be + phần nhấn + that/who + phần còn lại.\n• It was Mai who called. (nhấn vào người)\n• It was yesterday that I saw him. (nhấn vào thời gian)\n• It is practice that improves your English.\n\nNghĩa cơ bản không đổi so với câu thường. Chỉ đổi trọng tâm.",
    ["It was Lan who found the keys.", "It is the ending that surprised me."],
    [
      ["___ was John who broke the window.", "It", ["It", "There", "That", "What"]],
      ["It was in Hanoi ___ we first met.", "that", ["that", "which", "where that", "what"]],
      ["It is practice ___ makes you fluent.", "that", ["that", "what", "who", "which it"]]
    ]
  ),
  topic(
    "Inversion",
    "Đảo ngữ sau trạng từ phủ định",
    "C1", 22,
    "Never / Rarely / Not only + trợ động từ + chủ ngữ",
    "Sau một số trạng từ mang nghĩa phủ định hoặc hạn chế đặt đầu câu, trợ động từ đứng trước chủ ngữ.\n\n• Never have I seen such a crowd.\n• Rarely does she complain.\n• Not only did he arrive late, but he also forgot the file.\n• Hardly had I sat down when the phone rang.\n\nNếu không có trợ động từ, dùng do/does/did.",
    ["Never have I heard that song.", "Not only did she pass, but she also got the prize."],
    [
      ["Never ___ I seen such a beautiful beach.", "have", ["have", "did", "I have", "has"]],
      ["Rarely ___ he raise his voice.", "does", ["does", "do", "is", "has"]],
      ["Not only ___ she apologize, but she also paid for the damage.", "did", ["did", "does", "had", "was"]]
    ]
  ),
  topic(
    "Noun clauses",
    "Mệnh đề danh từ với that, if và wh-",
    "B2", 24,
    "that / if / wh- làm chủ ngữ hoặc tân ngữ",
    "Mệnh đề danh từ đóng vai trò như một danh từ: làm tân ngữ hoặc chủ ngữ.\n\n• I think that the plan will work.\n• She doesn't know if the shop is open.\n• What he said surprised everyone.\n• The question is whether we should wait.\n\nthat có thể lược bỏ khi mệnh đề là tân ngữ: I think the plan will work. Không đảo ngữ trong mệnh đề này.",
    ["I believe that she is right.", "What you need is more practice."],
    [
      ["I don't know ___ the train has left.", "whether", ["whether", "that if", "what if", "which"]],
      ["___ she said was true.", "What", ["What", "That what", "Which", "If"]],
      ["He explained ___ he was late.", "that", ["that", "what", "which", "if that"]]
    ]
  )
]

errors = []
topics.each do |item|
  errors << "trùng #{item["title"]}" if known.include?(item["title"])
  errors << "mô tả dài: #{item["title"]}" if item["description"].length > 250
  item["lessons"].each do |lesson|
    lesson["examples"].each do |example|
      errors << "ví dụ dài: #{item["title"]}" if example["en"].length > 250
    end
    lesson["exercises"].each do |exercise|
      errors << "câu hỏi dài: #{item["title"]}" if exercise["question"].length > 250
      errors << "đáp án dài: #{item["title"]}" if exercise["answer"].length > 250
      unless exercise["options"].include?(exercise["answer"])
        errors << "đáp án không nằm trong lựa chọn: #{item["title"]} / #{exercise["answer"]}"
      end
      exercise["options"].each do |option|
        errors << "lựa chọn dài: #{item["title"]}" if option.length > 250
      end
    end
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

data["topics"].concat(topics)
File.write(path, JSON.pretty_generate(data) + "\n")
puts "grammar_topics=#{data["topics"].size} added=#{topics.size}"
