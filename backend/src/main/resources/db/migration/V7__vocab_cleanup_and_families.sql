-- 1. Loại khỏi bộ từ vựng các mục không phù hợp với app học: từ tục và miệt thị, từ tình dục quá trực diện,
-- tên riêng và thương hiệu, tính từ quốc tịch viết thường, từ cảm thán vô nghĩa, dạng chia bị lấy làm từ gốc.
-- Các mục này đến từ danh sách tần suất phụ đề phim. Seeder không xoá từ đã có nên phải xoá bằng migration.
-- Từ trung tính có thể gặp trong bài đọc (rape, heroin, homosexual...) được giữ lại.
CREATE TABLE removed_words (word VARCHAR(255) PRIMARY KEY);
INSERT INTO removed_words (word) VALUES
  ('afghan'), ('african'), ('ahem'), ('american'), ('arab'), ('arabic'), ('asap'), ('asian'), ('ass'), ('asshole'),
  ('atm'), ('australian'), ('austrian'), ('authorities'), ('bao'), ('bastard'), ('beep'), ('belgian'), ('bitch'), ('bleeding'),
  ('bloody'), ('boo'), ('booby'), ('bowels'), ('breathing'), ('british'), ('brothel'), ('buddha'), ('buddhist'), ('bullshit'),
  ('burnt'), ('butt'), ('canadian'), ('capitol'), ('castrate'), ('catholic'), ('caucasian'), ('cee'), ('ceo'), ('chi'),
  ('chinatown'), ('chinese'), ('clubs'), ('cock'), ('colored'), ('concubine'), ('contents'), ('crap'), ('croatian'), ('crushed'),
  ('cum'), ('cunt'), ('czech'), ('damn'), ('danish'), ('daphne'), ('darn'), ('dee'), ('diamonds'), ('dick'),
  ('digits'), ('directions'), ('don'), ('dong'), ('dripping'), ('dropping'), ('duke'), ('dutch'), ('dyke'), ('earl'),
  ('easter'), ('egyptian'), ('erection'), ('erotic'), ('european'), ('fag'), ('fart'), ('finals'), ('flooded'), ('ford'),
  ('french'), ('frenchman'), ('fuck'), ('german'), ('gong'), ('gospel'), ('greek'), ('grub'), ('haha'), ('heads'),
  ('hearts'), ('hebrew'), ('hindu'), ('honk'), ('hooray'), ('horny'), ('hubby'), ('huh'), ('hump'), ('hungarian'),
  ('hurrah'), ('icu'), ('imbecile'), ('indian'), ('intercourse'), ('irish'), ('islamic'), ('italian'), ('jack'), ('japanese'),
  ('jesus'), ('jew'), ('jewish'), ('khan'), ('kip'), ('korean'), ('kurdish'), ('lao'), ('latin'), ('lent'),
  ('lingerie'), ('lit'), ('lithuanian'), ('locked'), ('looks'), ('lord'), ('lust'), ('lustful'), ('madeleine'), ('maltese'),
  ('mara'), ('marxist'), ('mason'), ('masturbate'), ('meow'), ('mercedes'), ('messiah'), ('midget'), ('miller'), ('mon'),
  ('motherfucker'), ('muslim'), ('nay'), ('nazi'), ('negro'), ('nigger'), ('nipple'), ('norwegian'), ('nova'), ('nude'),
  ('orgasm'), ('ouch'), ('pakistani'), ('panties'), ('pee'), ('penis'), ('persian'), ('pharaoh'), ('phew'), ('pimp'),
  ('piss'), ('planned'), ('pointed'), ('poop'), ('pope'), ('portuguese'), ('protestant'), ('psst'), ('pussy'), ('quack'),
  ('reich'), ('republican'), ('rigged'), ('roman'), ('rowan'), ('russian'), ('saying'), ('scales'), ('scoot'), ('semen'),
  ('sensual'), ('serb'), ('serbian'), ('serving'), ('sexy'), ('shag'), ('shah'), ('shh'), ('shit'), ('slut'),
  ('smoked'), ('smurf'), ('snot'), ('spades'), ('spanish'), ('sperm'), ('spoke'), ('squeak'), ('squirt'), ('statues'),
  ('stoned'), ('studies'), ('superman'), ('swastika'), ('swiss'), ('tai'), ('tails'), ('tamil'), ('thai'), ('thingy'),
  ('thou'), ('thud'), ('touching'), ('tsar'), ('turk'), ('turkish'), ('twat'), ('ufo'), ('uh-huh'), ('uh-oh'),
  ('vagina'), ('vietnamese'), ('viking'), ('virginity'), ('wah'), ('wai'), ('wellington'), ('whew'), ('whine'), ('whore'),
  ('woe'), ('woof'), ('wow'), ('xiao'), ('yang'), ('yao'), ('yay'), ('yeah'), ('yen'), ('yep'),
  ('yin'), ('yuan'), ('yuck');

DELETE FROM srs_cards
WHERE content_type = 'VOCABULARY'
  AND content_id IN (SELECT v.id FROM vocabulary v JOIN removed_words r ON LOWER(v.word) = r.word);
DELETE FROM dictation_attempts
WHERE vocab_id IN (SELECT v.id FROM vocabulary v JOIN removed_words r ON LOWER(v.word) = r.word);
DELETE FROM vocabulary WHERE LOWER(word) IN (SELECT word FROM removed_words);
DROP TABLE removed_words;

-- 2. Họ từ (analyse → analysis → analytical...), nạp từ trường "family" trong content/vocab.json.
ALTER TABLE vocabulary ADD COLUMN word_family VARCHAR(500);
