-- Đợt dọn thứ hai sau khi rà nghĩa toàn bộ từ vựng (scripts/vocab-review): tên riêng, quốc tịch, từ tình dục
-- trực diện, từ tượng thanh, từ chỉ gặp trong truyện/phim và mục bị gán sai nghĩa không sửa được.
-- Seeder không xoá từ đã có nên phải xoá bằng migration, cùng thẻ SRS và lượt nghe chép của các từ này.
CREATE TABLE removed_words (word VARCHAR(255) PRIMARY KEY);
INSERT INTO removed_words (word) VALUES
  ('a-bomb'), ('abracadabra'), ('algerian'), ('amulet'), ('anglo-saxon'), ('antichrist'), ('arabian'), ('armenian'), ('ashram'), ('ashtray'),
  ('aye-aye'), ('baht'), ('bai'), ('banjo'), ('banzai'), ('bellows'), ('blowjob'), ('bogeyman'), ('bolshevik'), ('booger'),
  ('brandy'), ('bulgarian'), ('burmese'), ('burp'), ('buzzard'), ('cantonese'), ('carmine'), ('chink'), ('chop-chop'), ('chow'),
  ('circumcision'), ('clitoris'), ('cluck'), ('cocky'), ('cognac'), ('commie'), ('congee'), ('coo'), ('coot'), ('cossack'),
  ('countess'), ('courtesan'), ('cuckold'), ('deva'), ('dharma'), ('dojo'), ('dwarfism'), ('earthling'), ('emery'), ('eureka'),
  ('fetish'), ('finnish'), ('fisher'), ('floe'), ('gallows'), ('geisha'), ('georgian'), ('gigolo'), ('gladiator'), ('godspeed'),
  ('grunt'), ('guillotine'), ('hag'), ('harem'), ('harrow'), ('hashish'), ('hearse'), ('heathen'), ('heterosexual'), ('hick'),
  ('hui'), ('hydra'), ('icelandic'), ('incest'), ('indonesian'), ('intubate'), ('iranian'), ('jingle'), ('kamikaze'), ('kanji'),
  ('knock-knock'), ('koto'), ('lama'), ('lasso'), ('lobotomy'), ('lol'), ('lynch'), ('machete'), ('mahjong'), ('masturbation'),
  ('merc'), ('mikado'), ('mongolian'), ('monsignor'), ('moroccan'), ('musketeer'), ('ninety-nine'), ('ninja'), ('nom'), ('noose'),
  ('oink'), ('orbital'), ('ornery'), ('ottoman'), ('pager'), ('palanquin'), ('pedophile'), ('pika'), ('pip'), ('playboy'),
  ('plutocrat'), ('poltergeist'), ('polysyllabic'), ('pornographic'), ('potion'), ('rishi'), ('rom'), ('ronin'), ('roulette'), ('rum'),
  ('rye'), ('sakura'), ('samurai'), ('saxon'), ('scarecrow'), ('schnapps'), ('scrotum'), ('scythe'), ('shangri-la'), ('shogunate'),
  ('slag'), ('snort'), ('spaniard'), ('squawk'), ('striptease'), ('swordsman'), ('taiwanese'), ('talisman'), ('tampon'), ('taoist'),
  ('taser'), ('tee'), ('teleport'), ('testicle'), ('thirty-six'), ('thong'), ('thoracic'), ('tick-tock'), ('toot'), ('topless'),
  ('tov'), ('triad'), ('tuxedo'), ('vasectomy'), ('vee'), ('vendetta'), ('vibrator'), ('videotape'), ('viscount'), ('vizier'),
  ('vodka'), ('walkie-talkie'), ('wand'), ('werewolf'), ('wolverine'), ('wonderland'), ('yap'), ('zombie');

DELETE FROM srs_cards
WHERE content_type = 'VOCABULARY'
  AND content_id IN (SELECT v.id FROM vocabulary v JOIN removed_words r ON LOWER(v.word) = r.word);
DELETE FROM dictation_attempts
WHERE vocab_id IN (SELECT v.id FROM vocabulary v JOIN removed_words r ON LOWER(v.word) = r.word);
DELETE FROM vocabulary WHERE LOWER(word) IN (SELECT word FROM removed_words);
DROP TABLE removed_words;
