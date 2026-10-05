import { PrismaClient, EnglishLevel, PartOfSpeech } from "./generated/client";
import { resolveVocabImage } from "@edu/vocab-images";

const prisma = new PrismaClient();

async function main() {
  // Topics
  const topicDaily = await prisma.vocabTopic.upsert({
    where: { name: 'Daily Life' },
    update: {},
    create: { name: 'Daily Life', icon: '🏠' },
  });
  const topicWork = await prisma.vocabTopic.upsert({
    where: { name: 'Work & Career' },
    update: {},
    create: { name: 'Work & Career', icon: '💼' },
  });
  const topicTravel = await prisma.vocabTopic.upsert({
    where: { name: 'Travel' },
    update: {},
    create: { name: 'Travel', icon: '✈️' },
  });

  // A1 Vocabulary
  const a1Words = [
    { word: 'hello', phonetic: '/həˈloʊ/', meaningVi: 'xin chào', level: 'A1', partOfSpeech: 'interjection', exampleEn: 'Hello, how are you?', exampleVi: 'Xin chào, bạn khỏe không?', topicId: topicDaily.id },
    { word: 'goodbye', phonetic: '/ˌɡʊdˈbaɪ/', meaningVi: 'tạm biệt', level: 'A1', partOfSpeech: 'interjection', exampleEn: 'Goodbye, see you tomorrow!', exampleVi: 'Tạm biệt, hẹn gặp lại ngày mai!', topicId: topicDaily.id },
    { word: 'house', phonetic: '/haʊs/', meaningVi: 'ngôi nhà', level: 'A1', partOfSpeech: 'noun', exampleEn: 'I live in a small house.', exampleVi: 'Tôi sống trong một ngôi nhà nhỏ.', topicId: topicDaily.id },
    { word: 'water', phonetic: '/ˈwɔːtər/', meaningVi: 'nước', level: 'A1', partOfSpeech: 'noun', exampleEn: 'Can I have some water?', exampleVi: 'Tôi có thể xin chút nước không?', topicId: topicDaily.id },
    { word: 'eat', phonetic: '/iːt/', meaningVi: 'ăn', level: 'A1', partOfSpeech: 'verb', exampleEn: 'I eat breakfast every morning.', exampleVi: 'Tôi ăn sáng mỗi buổi sáng.', topicId: topicDaily.id },
    { word: 'book', phonetic: '/bʊk/', meaningVi: 'quyển sách', level: 'A1', partOfSpeech: 'noun', exampleEn: 'This is a good book.', exampleVi: 'Đây là một cuốn sách hay.', topicId: topicDaily.id },
    { word: 'friend', phonetic: '/frend/', meaningVi: 'bạn bè', level: 'A1', partOfSpeech: 'noun', exampleEn: 'She is my best friend.', exampleVi: 'Cô ấy là người bạn thân nhất của tôi.', topicId: topicDaily.id },
    { word: 'happy', phonetic: '/ˈhæpi/', meaningVi: 'vui vẻ, hạnh phúc', level: 'A1', partOfSpeech: 'adjective', exampleEn: 'I am very happy today.', exampleVi: 'Hôm nay tôi rất vui.', topicId: topicDaily.id },
    { word: 'work', phonetic: '/wɜːrk/', meaningVi: 'làm việc / công việc', level: 'A1', partOfSpeech: 'verb', exampleEn: 'I work in an office.', exampleVi: 'Tôi làm việc trong văn phòng.', topicId: topicWork.id },
    { word: 'school', phonetic: '/skuːl/', meaningVi: 'trường học', level: 'A1', partOfSpeech: 'noun', exampleEn: 'My school is near my house.', exampleVi: 'Trường tôi gần nhà tôi.', topicId: topicDaily.id },
  ];

  // A2 Vocabulary
  const a2Words = [
    { word: 'although', phonetic: '/ɔːlˈðoʊ/', meaningVi: 'mặc dù', level: 'A2', partOfSpeech: 'conjunction', exampleEn: 'Although it was raining, we went out.', exampleVi: 'Mặc dù trời mưa, chúng tôi vẫn ra ngoài.', topicId: topicDaily.id },
    { word: 'journey', phonetic: '/ˈdʒɜːrni/', meaningVi: 'hành trình', level: 'A2', partOfSpeech: 'noun', exampleEn: 'The journey took three hours.', exampleVi: 'Hành trình mất ba tiếng đồng hồ.', topicId: topicTravel.id },
    { word: 'describe', phonetic: '/dɪˈskraɪb/', meaningVi: 'mô tả', level: 'A2', partOfSpeech: 'verb', exampleEn: 'Can you describe what you saw?', exampleVi: 'Bạn có thể mô tả những gì bạn thấy không?', topicId: topicDaily.id },
    { word: 'popular', phonetic: '/ˈpɒpjʊlər/', meaningVi: 'phổ biến', level: 'A2', partOfSpeech: 'adjective', exampleEn: 'This song is very popular.', exampleVi: 'Bài hát này rất phổ biến.', topicId: topicDaily.id },
    { word: 'passport', phonetic: '/ˈpæspɔːrt/', meaningVi: 'hộ chiếu', level: 'A2', partOfSpeech: 'noun', exampleEn: 'You need a passport to travel abroad.', exampleVi: 'Bạn cần hộ chiếu để đi nước ngoài.', topicId: topicTravel.id },
  ];

  // B1 Vocabulary
  const b1Words = [
    { word: 'negotiate', phonetic: '/nɪˈɡoʊʃieɪt/', meaningVi: 'đàm phán, thương lượng', level: 'B1', partOfSpeech: 'verb', exampleEn: 'We need to negotiate the contract terms.', exampleVi: 'Chúng ta cần thương lượng các điều khoản hợp đồng.', topicId: topicWork.id },
    { word: 'significant', phonetic: '/sɪɡˈnɪfɪkənt/', meaningVi: 'đáng kể, quan trọng', level: 'B1', partOfSpeech: 'adjective', exampleEn: 'There has been a significant improvement.', exampleVi: 'Đã có sự cải thiện đáng kể.', topicId: topicWork.id },
    { word: 'recommend', phonetic: '/ˌrekəˈmend/', meaningVi: 'đề nghị, giới thiệu', level: 'B1', partOfSpeech: 'verb', exampleEn: 'I recommend this restaurant.', exampleVi: 'Tôi giới thiệu nhà hàng này.', topicId: topicTravel.id },
    { word: 'efficient', phonetic: '/ɪˈfɪʃənt/', meaningVi: 'hiệu quả', level: 'B1', partOfSpeech: 'adjective', exampleEn: 'She is a very efficient worker.', exampleVi: 'Cô ấy là một nhân viên rất hiệu quả.', topicId: topicWork.id },
    { word: 'approximately', phonetic: '/əˈprɒksɪmətli/', meaningVi: 'xấp xỉ, khoảng', level: 'B1', partOfSpeech: 'adverb', exampleEn: 'It costs approximately $50.', exampleVi: 'Nó có giá khoảng 50 đô la.', topicId: topicWork.id },
  ];

  for (const [i, w] of [...a1Words, ...a2Words, ...b1Words].entries()) {
    const imageUrl = resolveVocabImage({ word: w.word, meaning: w.meaningVi });
    await prisma.vocabulary.create({
      data: {
        ...w,
        level: w.level as EnglishLevel,
        partOfSpeech: w.partOfSpeech as PartOfSpeech,
        sortOrder: i,
        imageUrl,
      },
    });
  }
  console.log(`✅ Created ${a1Words.length + a2Words.length + b1Words.length} vocabulary words`);

  // Grammar
  await prisma.grammarTopic.create({
    data: {
      title: 'Present Simple',
      description: 'Thì hiện tại đơn — diễn tả thói quen, sự thật chung',
      level: 'A1',
      sortOrder: 1,
      lessons: {
        create: {
          title: 'Cách dùng & cấu trúc',
          level: 'A1',
          sortOrder: 1,
          explanation: `Present Simple (Thì hiện tại đơn) dùng để:
1. Diễn tả thói quen, việc lặp đi lặp lại
   → I drink coffee every morning.
2. Diễn tả sự thật hiển nhiên, chân lý
   → The sun rises in the east.
3. Diễn tả lịch trình cố định
   → The train leaves at 8am.

Cấu trúc:
(+) S + V(s/es)     → She works hard.
(-) S + don't/doesn't + V → He doesn't like tea.
(?) Do/Does + S + V? → Do you speak English?

Lưu ý: Thêm -s/-es với he/she/it`,
          examples: [
            'She speaks English very well.',
            'We don\'t eat meat on Fridays.',
            'Does he play football?',
          ],
          exercises: {
            create: [
              { question: 'She ___ (work) at a hospital.', answer: 'works', options: JSON.stringify(['work', 'works', 'working', 'worked']), sortOrder: 1 },
              { question: 'They ___ (not/eat) fast food.', answer: "don't eat", options: JSON.stringify(["don't eat", "doesn't eat", "not eat", "aren't eat"]), sortOrder: 2 },
              { question: '___ he ___ (speak) French?', answer: 'Does / speak', options: JSON.stringify(['Does / speak', 'Do / speaks', 'Is / speak', 'Has / speak']), sortOrder: 3 },
              { question: 'Water ___ (boil) at 100°C.', answer: 'boils', options: JSON.stringify(['boil', 'boils', 'is boiling', 'boiled']), sortOrder: 4 },
            ],
          },
        },
      },
    },
  });

  await prisma.grammarTopic.create({
    data: {
      title: 'Present Continuous',
      description: 'Thì hiện tại tiếp diễn — đang xảy ra lúc nói',
      level: 'A1',
      sortOrder: 2,
      lessons: {
        create: {
          title: 'Cách dùng & cấu trúc',
          level: 'A1',
          sortOrder: 1,
          explanation: `Present Continuous (Thì hiện tại tiếp diễn) dùng để:
1. Diễn tả hành động đang xảy ra tại thời điểm nói
   → I am reading a book right now.
2. Diễn tả sự thay đổi hoặc xu hướng
   → Prices are rising.
3. Diễn tả kế hoạch trong tương lai gần
   → I am meeting him tomorrow.

Cấu trúc:
(+) S + am/is/are + V-ing
(-) S + am/is/are + not + V-ing
(?) Am/Is/Are + S + V-ing?`,
          examples: [
            'She is watching TV now.',
            'They aren\'t working today.',
            'Are you listening to me?',
          ],
          exercises: {
            create: [
              { question: 'Listen! She ___ (sing).', answer: 'is singing', options: JSON.stringify(['sings', 'is singing', 'are singing', 'was singing']), sortOrder: 1 },
              { question: 'We ___ (not/watch) TV right now.', answer: "aren't watching", options: JSON.stringify(["aren't watching", "don't watch", "isn't watching", "not watching"]), sortOrder: 2 },
              { question: '___ they ___ (study) for the exam?', answer: 'Are / studying', options: JSON.stringify(['Are / studying', 'Do / study', 'Is / studying', 'Have / studying']), sortOrder: 3 },
            ],
          },
        },
      },
    },
  });

  await prisma.grammarTopic.create({
    data: {
      title: 'Conditional Sentences',
      description: 'Câu điều kiện loại 1, 2, 3',
      level: 'B1',
      sortOrder: 1,
      lessons: {
        create: [
          {
            title: 'Conditional Type 1',
            level: 'B1',
            sortOrder: 1,
            explanation: `Câu điều kiện loại 1 — điều kiện có thể xảy ra ở hiện tại/tương lai

Cấu trúc: If + S + V(simple present), S + will + V

Dùng khi: điều kiện có thể xảy ra, khả năng thực hiện được

Ví dụ:
• If it rains, I will stay at home.
• If you study hard, you will pass the exam.
• We will be late if we don't hurry.`,
            examples: ['If I have time, I will call you.', 'She will help if you ask her.'],
            exercises: {
              create: [
                { question: 'If it ___ (rain), we ___ (cancel) the picnic.', answer: 'rains / will cancel', options: JSON.stringify(['rains / will cancel', 'rained / would cancel', 'will rain / cancel', 'rains / cancel']), sortOrder: 1 },
                { question: 'She ___ (be) angry if you ___ (be) late.', answer: 'will be / are', options: JSON.stringify(['will be / are', 'would be / were', 'is / will be', 'will be / will be']), sortOrder: 2 },
              ],
            },
          },
          {
            title: 'Conditional Type 2',
            level: 'B1',
            sortOrder: 2,
            explanation: `Câu điều kiện loại 2 — giả thuyết không có thật ở hiện tại

Cấu trúc: If + S + V(past simple), S + would + V

Dùng khi: tình huống không có thật, không thể xảy ra hoặc khó xảy ra

Ví dụ:
• If I were rich, I would travel the world.
• If I had more time, I would learn more languages.
• She would help if she knew how.

Lưu ý: Với "to be" dùng "were" cho mọi chủ ngữ (I were, he were...)`,
            examples: ['If I were you, I would accept the job.', 'What would you do if you won the lottery?'],
            exercises: {
              create: [
                { question: 'If I ___ (be) you, I ___ (study) harder.', answer: 'were / would study', options: JSON.stringify(['were / would study', 'was / will study', 'am / would study', 'were / will study']), sortOrder: 1 },
              ],
            },
          },
        ],
      },
    },
  });

  console.log(`✅ Created grammar topics`);

  // Reading passages
  await prisma.readingPassage.create({
    data: {
      title: 'My Daily Routine',
      level: 'A1',
      estimatedMin: 3,
      sortOrder: 1,
      content: `My name is Lan. I am a student. Every day, I wake up at 6 o'clock in the morning. I wash my face and brush my teeth. Then I eat breakfast with my family.

I go to school at 7 o'clock. I walk to school because my school is near my house. At school, I study Math, English, and Science.

After school, I go home at 5 o'clock. I do my homework and then I watch TV. I eat dinner at 7 o'clock. I read a book before I sleep. I go to bed at 10 o'clock.`,
      questions: {
        create: [
          {
            question: 'What time does Lan wake up?',
            answer: '6 o\'clock',
            sortOrder: 1,
            options: { create: [{ text: '5 o\'clock', sortOrder: 1 }, { text: '6 o\'clock', sortOrder: 2 }, { text: '7 o\'clock', sortOrder: 3 }, { text: '8 o\'clock', sortOrder: 4 }] },
          },
          {
            question: 'How does Lan go to school?',
            answer: 'She walks',
            sortOrder: 2,
            options: { create: [{ text: 'By bus', sortOrder: 1 }, { text: 'By bicycle', sortOrder: 2 }, { text: 'She walks', sortOrder: 3 }, { text: 'By car', sortOrder: 4 }] },
          },
          {
            question: 'What does Lan do before sleeping?',
            answer: 'She reads a book',
            sortOrder: 3,
            options: { create: [{ text: 'She watches TV', sortOrder: 1 }, { text: 'She does homework', sortOrder: 2 }, { text: 'She reads a book', sortOrder: 3 }, { text: 'She plays games', sortOrder: 4 }] },
          },
        ],
      },
    },
  });

  await prisma.readingPassage.create({
    data: {
      title: 'The Benefits of Learning English',
      level: 'B1',
      estimatedMin: 5,
      sortOrder: 1,
      source: 'Adapted from various sources',
      content: `English is one of the most widely spoken languages in the world. More than 1.5 billion people speak English, either as their first or second language. Learning English can open many doors for you in life.

First, English is the language of international business. Many multinational companies require their employees to speak English. If you can communicate effectively in English, you will have a significant advantage in the job market.

Second, most scientific research and academic papers are published in English. Students who can read English have access to a much wider range of educational resources and can stay up-to-date with the latest developments in their fields.

Third, English is the primary language of the internet. A large percentage of websites, videos, and online content are in English. Being able to understand English allows you to access this vast amount of information.

Finally, learning English can help you understand different cultures and connect with people from all over the world. Travel becomes easier when you can communicate in English, as it is understood in most tourist destinations.`,
      questions: {
        create: [
          {
            question: 'According to the passage, how many people speak English?',
            answer: 'More than 1.5 billion',
            sortOrder: 1,
            options: { create: [{ text: 'More than 1 billion', sortOrder: 1 }, { text: 'More than 1.5 billion', sortOrder: 2 }, { text: 'More than 2 billion', sortOrder: 3 }, { text: 'About 500 million', sortOrder: 4 }] },
          },
          {
            question: 'Why is English important in business?',
            answer: 'Multinational companies require employees to speak English',
            explanation: 'The passage states that many multinational companies require their employees to speak English.',
            sortOrder: 2,
            options: {
              create: [
                { text: 'It is the official language of all countries', sortOrder: 1 },
                { text: 'Multinational companies require employees to speak English', sortOrder: 2 },
                { text: 'It is easy to learn', sortOrder: 3 },
                { text: 'It helps you make more money immediately', sortOrder: 4 },
              ],
            },
          },
          {
            question: 'What percentage of the internet is in English?',
            answer: 'A large percentage',
            sortOrder: 3,
            options: { create: [{ text: '50%', sortOrder: 1 }, { text: '75%', sortOrder: 2 }, { text: 'A large percentage', sortOrder: 3 }, { text: 'Almost all of it', sortOrder: 4 }] },
          },
        ],
      },
    },
  });

  console.log(`✅ Created reading passages`);

  // Listening tracks
  await prisma.listeningTrack.create({
    data: {
      title: 'Introduction to English Pronunciation',
      level: 'A1',
      sortOrder: 1,
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      transcript: 'This is a sample transcript for the listening exercise. In real usage, you would add the actual transcript of the YouTube video here.',
      durationSec: 300,
      questions: {
        create: [
          {
            question: 'What is the main topic of this lesson?',
            answer: 'English pronunciation',
            sortOrder: 1,
            options: { create: [{ text: 'English grammar', sortOrder: 1 }, { text: 'English pronunciation', sortOrder: 2 }, { text: 'English vocabulary', sortOrder: 3 }, { text: 'English writing', sortOrder: 4 }] },
          },
        ],
      },
    },
  });

  console.log(`✅ Created listening tracks`);
  console.log('\n🎉 Seed completed!');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
