-- 1. Mức ưu tiên của từ: CORE (cốt lõi cho IELTS) hoặc EXTRA (từ hiếm lấy từ tần suất phụ đề, ít gặp trong đề).
-- Seeder đặt giá trị theo trường "priority" trong content/vocab.json; mặc định CORE.
ALTER TABLE vocabulary ADD COLUMN priority VARCHAR(10) DEFAULT 'CORE' NOT NULL;

-- 2. Gộp các cặp chính tả Anh–Mỹ: giữ cách viết Anh (IELTS theo chuẩn Anh), chuyển tiến độ SRS và lượt nghe chép
-- của thẻ Mỹ sang thẻ Anh. Người đã có cả hai thẻ thì giữ thẻ Anh, bỏ thẻ Mỹ.
CREATE TABLE spelling_merge (us_word VARCHAR(255) PRIMARY KEY, uk_word VARCHAR(255) NOT NULL);
INSERT INTO spelling_merge (us_word, uk_word) VALUES
  ('dialog', 'dialogue'), ('harbor', 'harbour'), ('honor', 'honour'), ('neighbor', 'neighbour'),
  ('utilize', 'utilise'), ('generalization', 'generalisation'), ('skillful', 'skilful');

UPDATE srs_cards
SET content_id = (
  SELECT uk.id FROM vocabulary uk JOIN spelling_merge m ON LOWER(uk.word) = m.uk_word
  JOIN vocabulary us ON LOWER(us.word) = m.us_word WHERE us.id = srs_cards.content_id)
WHERE content_type = 'VOCABULARY'
  AND content_id IN (SELECT us.id FROM vocabulary us JOIN spelling_merge m ON LOWER(us.word) = m.us_word
                     JOIN vocabulary uk ON LOWER(uk.word) = m.uk_word)
  AND NOT EXISTS (
    SELECT 1 FROM srs_cards other
    JOIN vocabulary uk ON uk.id = other.content_id
    JOIN spelling_merge m ON LOWER(uk.word) = m.uk_word
    JOIN vocabulary us ON LOWER(us.word) = m.us_word
    WHERE other.user_id = srs_cards.user_id AND other.content_type = 'VOCABULARY' AND us.id = srs_cards.content_id);

UPDATE dictation_attempts
SET vocab_id = (
  SELECT uk.id FROM vocabulary uk JOIN spelling_merge m ON LOWER(uk.word) = m.uk_word
  JOIN vocabulary us ON LOWER(us.word) = m.us_word WHERE us.id = dictation_attempts.vocab_id)
WHERE vocab_id IN (SELECT us.id FROM vocabulary us JOIN spelling_merge m ON LOWER(us.word) = m.us_word
                   JOIN vocabulary uk ON LOWER(uk.word) = m.uk_word);

DELETE FROM srs_cards
WHERE content_type = 'VOCABULARY'
  AND content_id IN (SELECT us.id FROM vocabulary us JOIN spelling_merge m ON LOWER(us.word) = m.us_word
                     JOIN vocabulary uk ON LOWER(uk.word) = m.uk_word);
DELETE FROM vocabulary
WHERE id IN (SELECT us.id FROM vocabulary us JOIN spelling_merge m ON LOWER(us.word) = m.us_word
             JOIN vocabulary uk ON LOWER(uk.word) = m.uk_word);
DROP TABLE spelling_merge;
