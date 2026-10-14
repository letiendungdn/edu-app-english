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
    "Imperatives",
    "Câu mệnh lệnh — yêu cầu, hướng dẫn, lời khuyên",
    "A1", 30,
    "Động từ nguyên mẫu đứng đầu câu",
    "Câu mệnh lệnh dùng động từ nguyên mẫu, không có chủ ngữ.\n• Open the door.\n• Don't be late.\n\nDùng để ra lệnh, hướng dẫn hoặc khuyên.\nPlease làm câu lịch sự hơn: Please sit down.\nLet's + động từ mời cùng làm: Let's go.",
    ["Open your book.", "Don't talk in the library.", "Let's start."],
    [
      ["___ the window, please.", "Open", ["Open", "Opens", "Opening", "To open"]],
      ["___ late.", "Don't be", ["Don't be", "Not be", "Doesn't be", "Aren't"]],
      ["___ go home.", "Let's", ["Let's", "Let", "Lets", "Let us to"]]
    ]
  ),
  topic(
    "This, that, these and those",
    "Đại từ và tính từ chỉ định",
    "A1", 31,
    "Gần và xa, số ít và số nhiều",
    "this / these chỉ vật gần. that / those chỉ vật xa.\nSố ít: this, that. Số nhiều: these, those.\n• This pen is mine. That pen is yours.\n• These shoes are new. Those shoes are old.\n\nĐứng trước danh từ hoặc đứng một mình: This is my bag.",
    ["This book is interesting.", "Those houses are far away."],
    [
      ["___ apple in my hand is red.", "This", ["This", "These", "Those", "Them"]],
      ["___ books over there are heavy.", "Those", ["Those", "This", "That", "Them"]],
      ["___ are my keys. (nhiều chìa khóa đang ở đây)", "These", ["These", "This", "That", "Those there"]]
    ]
  ),
  topic(
    "Plural nouns",
    "Danh từ số nhiều",
    "A1", 32,
    "Thêm -s, -es và dạng bất quy tắc",
    "Hầu hết danh từ thêm -s: book → books.\nThêm -es sau -s, -sh, -ch, -x, -o: bus → buses, box → boxes.\nĐổi -y thành -ies: city → cities.\nMột số bất quy tắc: child → children, man → men, foot → feet, tooth → teeth.\nSố nhiều đi với are, không đi với is.",
    ["There are two buses.", "The children are in the park."],
    [
      ["one box, two ___", "boxes", ["boxes", "boxs", "box", "boxies"]],
      ["one city, many ___", "cities", ["cities", "citys", "cityes", "city"]],
      ["The child ___ in the garden. (số nhiều)", "children are", ["children are", "childs are", "children is", "child are"]]
    ]
  ),
  topic(
    "Wh- questions",
    "Câu hỏi với who, what, where, when, why, how",
    "A1", 33,
    "Từ để hỏi + trợ động từ + chủ ngữ",
    "Wh- đứng đầu câu, sau đó là trợ động từ.\n• Where do you live?\n• What does she want?\n• When is the class?\n\nWho và what làm chủ ngữ thì không thêm do/does:\n• Who called you?\n• What happened?\n\nWhy hỏi lý do. How hỏi cách hoặc trạng thái: How are you?",
    ["Where do you live?", "Who called you?"],
    [
      ["Where ___ you live?", "do", ["do", "does", "are", "did you"]],
      ["What ___ she want?", "does", ["does", "do", "is", "has"]],
      ["___ called you? (hỏi người làm chủ ngữ)", "Who", ["Who", "Who did", "Whom does", "Which do"]]
    ]
  ),
  topic(
    "Subject and object pronouns",
    "Đại từ chủ ngữ và tân ngữ",
    "A1", 34,
    "I/you/he và me/you/him",
    "Chủ ngữ đứng trước động từ: I, you, he, she, it, we, they.\n• She likes tea.\n\nTân ngữ đứng sau động từ hoặc giới từ: me, you, him, her, it, us, them.\n• I like her. This gift is for them.\n\nKhông nói: Me is tired. Him likes coffee.",
    ["She called me.", "We saw them at school."],
    [
      ["___ am late. (tôi)", "I", ["I", "Me", "My", "Mine"]],
      ["Can you help ___? (tôi)", "me", ["me", "I", "my", "mine"]],
      ["I saw ___. (cô ấy)", "her", ["her", "she", "hers", "she's"]]
    ]
  ),
  topic(
    "Present perfect and past simple",
    "Khi nào dùng hiện tại hoàn thành, khi nào dùng quá khứ đơn",
    "A2", 30,
    "Kết quả còn lại và thời điểm đã kết thúc",
    "Past simple đi với thời điểm đã kết thúc: yesterday, last week, in 2020, ago.\n• I saw her yesterday.\n\nPresent perfect nối với hiện tại: already, yet, ever, never, since, for, hoặc không nói thời điểm.\n• I have already seen that film.\n• I have lived here since 2020.\n\nKhông dùng present perfect với yesterday hoặc last year.",
    ["I finished the book yesterday.", "I have never been to Hue."],
    [
      ["I ___ (see) that film yesterday.", "saw", ["saw", "have seen", "have saw", "seen"]],
      ["She ___ (live) here since 2019.", "has lived", ["has lived", "lived", "has live", "lives since"]],
      ["___ you ever ___ (eat) sushi?", "Have / eaten", ["Have / eaten", "Did / eaten", "Have / ate", "Did / ever eat"]]
    ]
  ),
  topic(
    "Could",
    "could — khả năng trong quá khứ và lời yêu cầu lịch sự",
    "A2", 31,
    "could / couldn't và Could you...?",
    "could là quá khứ của can khi nói khả năng chung.\n• I could swim when I was five.\n• She couldn't come yesterday.\n\nCould you...? là lời yêu cầu lịch sự, lịch sự hơn Can you...?\n• Could you repeat that, please?\n\nMột việc đã làm được trong một tình huống cụ thể thường dùng was able to, không dùng could.",
    ["I could ride a bike at six.", "Could you speak more slowly?"],
    [
      ["I ___ swim when I was six.", "could", ["could", "can", "could to", "was can"]],
      ["___ you help me, please?", "Could", ["Could", "Could to", "Do could", "Might to"]],
      ["She ___ come yesterday. She was ill.", "couldn't", ["couldn't", "can't", "could not to", "doesn't could"]]
    ]
  ),
  topic(
    "Both, either and neither",
    "both, either và neither — nói về hai người hoặc hai vật",
    "A2", 32,
    "Cả hai, một trong hai, không cái nào",
    "both = cả hai. Both answers are correct. Both of them came.\neither = một trong hai. You can take either road. Either of the books is fine.\nneither = không cái nào trong hai. Neither answer is correct.\n\neither... or... : một trong hai khả năng.\nneither... nor... : phủ định cả hai.\n• Neither Mai nor Lan was late.",
    ["Both students passed.", "Neither of the shops is open."],
    [
      ["___ answers are correct. (cả hai)", "Both", ["Both", "Either", "Neither", "All"]],
      ["___ answer is correct. (không cái nào)", "Neither", ["Neither", "Both", "Either are", "None are"]],
      ["You can sit on ___ chair. (một trong hai)", "either", ["either", "both", "neither", "all"]]
    ]
  ),
  topic(
    "A few and a little",
    "a few, few, a little và little",
    "A2", 33,
    "Đếm được và không đếm được",
    "a few + danh từ đếm được số nhiều: một vài, đủ dùng.\n• I have a few friends here.\n\nfew (không có a): rất ít, gần như không đủ.\n• Few people know the answer.\n\na little + danh từ không đếm được: một ít.\n• There is a little milk.\n\nlittle (không có a): rất ít, gần như không có.\n• There is little time.",
    ["I need a few minutes.", "There is little water left."],
    [
      ["I have ___ questions. (một vài câu)", "a few", ["a few", "a little", "few milk", "a little questions"]],
      ["There is ___ milk in the fridge. (một ít)", "a little", ["a little", "a few", "few", "many"]],
      ["___ people came, so the room was empty. (rất ít)", "Few", ["Few", "A few", "Little", "A little"]]
    ]
  ),
  topic(
    "Future perfect",
    "Thì tương lai hoàn thành — sẽ xong trước một mốc",
    "B1", 30,
    "will have + past participle",
    "Future perfect nói một việc sẽ đã hoàn thành trước một thời điểm trong tương lai.\n\nCấu trúc: S + will have + V3\n• By Friday I will have finished the essay.\n• She will have left before you arrive.\n\nMốc thời gian thường đi với by hoặc before.",
    ["By 8 p.m. I will have eaten.", "They will have arrived by noon."],
    [
      ["By Friday I ___ (finish) the essay.", "will have finished", ["will have finished", "will finish", "have finished", "will be finish"]],
      ["She ___ (leave) before you arrive.", "will have left", ["will have left", "will leave", "has left", "will has left"]],
      ["By June they ___ (live) here for ten years.", "will have lived", ["will have lived", "will live", "have lived", "will living"]]
    ]
  ),
  topic(
    "Past perfect continuous",
    "Thì quá khứ hoàn thành tiếp diễn",
    "B1", 31,
    "had been + V-ing",
    "Diễn tả một việc đã kéo dài đến một mốc trong quá khứ.\n\nCấu trúc: S + had been + V-ing\n• I had been waiting for an hour when the bus came.\n• She was tired because she had been working all day.\n\nNhấn vào thời lượng trước mốc quá khứ. Past perfect đơn nhấn vào việc đã xong: I had waited, then I left.",
    ["He had been running, so he was out of breath.", "We had been living there for a year when we moved."],
    [
      ["I ___ (wait) for an hour when she arrived.", "had been waiting", ["had been waiting", "have been waiting", "was waiting", "had waited been"]],
      ["She was tired because she ___ (work) all day.", "had been working", ["had been working", "has been working", "worked", "was work"]],
      ["How long ___ you ___ (study) before the test?", "had / been studying", ["had / been studying", "have / been studying", "did / study", "were / studying"]]
    ]
  ),
  topic(
    "Make, let and allow",
    "make, let và allow — bắt, cho phép",
    "B1", 32,
    "make/let + tân ngữ + động từ nguyên mẫu",
    "make + người + động từ nguyên mẫu (không to): bắt ai làm gì.\n• The teacher made us rewrite the essay.\n\nlet + người + động từ nguyên mẫu: cho phép.\n• My parents let me stay out late.\n\nallow lịch sự hơn và có to: allow + người + to + động từ.\n• The school allows students to use phones at lunch.\n\nBị động của make có to: We were made to wait.",
    ["She made me laugh.", "They let him go home early."],
    [
      ["The coach made us ___ (run).", "run", ["run", "to run", "running", "ran"]],
      ["My dad let me ___ (borrow) the car.", "borrow", ["borrow", "to borrow", "borrowing", "borrowed"]],
      ["The school allows students ___ (leave) early.", "to leave", ["to leave", "leave", "leaving", "left"]]
    ]
  ),
  topic(
    "Would rather and had better",
    "would rather và had better",
    "B1", 33,
    "Thích hơn và nên kẻo",
    "would rather + động từ nguyên mẫu: thích làm cái này hơn.\n• I would rather stay home.\n• I would rather walk than take a taxi.\n\nwould rather + chủ ngữ + quá khứ: muốn người khác làm điều trái với thực tế.\n• I would rather you didn't smoke here.\n\nhad better + động từ nguyên mẫu: nên làm, vì có hậu quả nếu không.\n• You had better leave now, or you will miss the bus.\nPhủ định: had better not.",
    ["I would rather tea than coffee.", "You had better call her."],
    [
      ["I would rather ___ (stay) home.", "stay", ["stay", "to stay", "staying", "stayed"]],
      ["I would rather you ___ (not/smoke) here.", "didn't smoke", ["didn't smoke", "don't smoke", "not smoke", "wouldn't smoke"]],
      ["You had better ___ late.", "not be", ["not be", "not to be", "don't be", "not being"]]
    ]
  ),
  topic(
    "Causative have and get",
    "Nhờ người khác làm — have/get something done",
    "B2", 30,
    "have/get + vật + past participle",
    "Dùng khi mình không tự làm mà sắp xếp để người khác làm.\n\nCấu trúc: have/get + vật + V3\n• I had my hair cut.\n• She got her phone repaired.\n• We will have the documents translated.\n\nhave + người + động từ nguyên mẫu cũng được: I had the barber cut my hair.\nget thì dùng to: I got the barber to cut my hair.",
    ["I had my watch repaired.", "They are getting the house painted."],
    [
      ["I had my hair ___.", "cut", ["cut", "cutting", "to cut", "cutted"]],
      ["She got her phone ___.", "repaired", ["repaired", "repair", "to repair", "repairing"]],
      ["We will have the letters ___.", "translated", ["translated", "translate", "to translate", "translating"]]
    ]
  ),
  topic(
    "If only",
    "if only — ước mạnh hơn wish",
    "B2", 31,
    "if only + quá khứ hoặc had + V3",
    "if only mang nghĩa ước, mạnh và thường tiếc nuối hơn wish.\n\nHiện tại trái sự thật: if only + quá khứ đơn.\n• If only I knew the answer.\n\nQuá khứ trái sự thật: if only + had + V3.\n• If only I had left earlier.\n\nVới to be ở hiện tại, were dùng được cho mọi chủ ngữ: If only I were taller.",
    ["If only I had more time.", "If only we hadn't missed the train."],
    [
      ["If only I ___ (know) her number.", "knew", ["knew", "know", "had known", "would know"]],
      ["If only she ___ (not/leave) yesterday.", "hadn't left", ["hadn't left", "didn't leave", "wouldn't leave", "hasn't left"]],
      ["If only I ___ taller.", "were", ["were", "am", "be", "was being"]]
    ]
  ),
  topic(
    "Needn't have",
    "needn't have và didn't need to",
    "B2", 32,
    "Đã làm một việc không cần thiết",
    "needn't have + V3: việc đã làm rồi, nhưng hóa ra không cần.\n• You needn't have brought food. We already had some.\n\ndidn't need to + động từ: không cần, và thường là đã không làm.\n• I didn't need to get up early, so I stayed in bed.\n\nneedn't (không có have) nói về hiện tại hoặc tương lai: You needn't come.",
    ["You needn't have waited. I took a taxi.", "I didn't need to cook. We ate out."],
    [
      ["You ___ brought a gift. We already had one. (bạn vẫn mang)", "needn't have", ["needn't have", "didn't need", "needn't", "mustn't have"]],
      ["I ___ get up early, so I slept. (không cần và không dậy)", "didn't need to", ["didn't need to", "needn't have", "needn't to", "haven't need"]],
      ["You ___ come tomorrow. It is a holiday.", "needn't", ["needn't", "needn't have", "don't need have", "mustn't have"]]
    ]
  ),
  topic(
    "Hedging",
    "Nói giảm, nói có chừng mực",
    "C2", 1,
    "seem, tend to, appear to",
    "Hedging làm câu bớt tuyệt đối, hợp văn học thuật.\n• The results seem to support the theory.\n• Learners tend to translate word for word.\n• It appears that the plan will work.\n• This may be due to a lack of practice.\n\nCác cách khác: it is likely that, to some extent, it could be argued that.",
    ["The data seem to show a small change.", "Students tend to avoid speaking."],
    [
      ["The results ___ support the idea.", "seem to", ["seem to", "seem", "are seem to", "seeming"]],
      ["Learners ___ translate every word.", "tend to", ["tend to", "tend", "are tend to", "tending"]],
      ["It ___ that the method works.", "appears", ["appears", "appear", "is appear", "appearing"]]
    ]
  ),
  topic(
    "Nominalisation",
    "Danh từ hóa — biến động từ hoặc tính từ thành danh từ",
    "C2", 2,
    "decide → decision, fail → failure",
    "Văn trang trọng thường dùng danh từ thay cho mệnh đề động từ.\n• They decided to leave. → Their decision to leave...\n• The city grew quickly. → the rapid growth of the city\n• People polluted the river. → pollution of the river\n\nDanh từ hóa làm câu cô đọng hơn, nhưng đừng biến mọi câu thành danh từ kẻo bài viết nặng.",
    ["Their decision surprised us.", "The rapid growth of the city caused traffic."],
    [
      ["They decided. → Their ___ surprised us.", "decision", ["decision", "decide", "deciding", "decisive"]],
      ["The city grew. → the rapid ___ of the city", "growth", ["growth", "grow", "growing", "grown"]],
      ["She failed the test. → Her ___ was unexpected.", "failure", ["failure", "fail", "failing", "failed"]]
    ]
  ),
  topic(
    "Emphasis",
    "Nhấn mạnh bằng do/does/did và mệnh đề what",
    "C2", 3,
    "I do understand. What I need is time.",
    "do/does/did đứng trước động từ thường để nhấn, khi người nghe đang nghi ngờ.\n• I do understand.\n• She did call you.\n\nMệnh đề what đưa phần muốn nhấn ra sau:\n• What I need is more time.\n• What surprised me was the ending.\n\nKhác câu chẻ It is... that..., dạng này bắt đầu bằng What.",
    ["I do agree with you.", "What we need is a clearer example."],
    [
      ["I ___ understand. Please believe me.", "do", ["do", "am", "have", "did do"]],
      ["She ___ call. I heard the phone.", "did", ["did", "does", "was", "had"]],
      ["___ I need is practice.", "What", ["What", "That", "It", "Which"]]
    ]
  ),
  topic(
    "Whatever and no matter",
    "whatever, whoever và no matter",
    "C2", 4,
    "Dù bất cứ cái gì, người nào, thế nào",
    "whatever = bất cứ cái gì. whoever = bất cứ ai. whenever = bất cứ khi nào. wherever = bất cứ nơi nào. however = dù thế nào.\n• Whatever you decide, I will help.\n• Whoever finishes first can leave.\n\nno matter + wh- có nghĩa gần giống:\n• No matter what you decide, I will help.\n• No matter how hard it is, keep going.\n\nhowever + tính từ: However tired you are, finish the page.",
    ["Whatever happens, call me.", "No matter how busy she is, she reads."],
    [
      ["___ you choose, I will agree.", "Whatever", ["Whatever", "What", "Whoever that", "No matter"]],
      ["___ finishes first can leave.", "Whoever", ["Whoever", "Whatever", "Who", "Whomever"]],
      ["No matter ___ tired you are, finish the page.", "how", ["how", "what", "however what", "which"]]
    ]
  ),
  topic(
    "Ellipsis",
    "Lược bỏ phần đã rõ để tránh lặp",
    "C2", 5,
    "Bỏ động từ hoặc mệnh đề khi người nghe đã biết",
    "Khi phần lặp đã rõ, có thể lược.\n• She can speak French, and he can too. (bỏ speak French)\n• I haven't finished, but she has. (bỏ finished)\n• A: Will you come? B: I might. (bỏ come)\n\nGiữ trợ động từ. Không lược khi người nghe không biết phần bị bỏ.\nTo + động từ có thể để trần to: I wanted to leave, but I decided not to.",
    ["Mai has finished, and Lan has too.", "I wanted to call, but I forgot to."],
    [
      ["She can swim, and he ___.", "can too", ["can too", "can swim too he", "too can", "does too swim"]],
      ["I haven't eaten, but she ___.", "has", ["has", "has eaten she", "is", "did"]],
      ["I wanted to go, but I decided not ___.", "to", ["to", "to go to", "going", "go"]]
    ]
  )
]

errors = []
fresh = []
topics.each do |item|
  next if known.include?(item["title"])
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
  fresh << item
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

data["topics"].concat(fresh)
File.write(path, JSON.pretty_generate(data) + "\n")
puts "grammar_topics=#{data["topics"].size} added=#{fresh.size}"
