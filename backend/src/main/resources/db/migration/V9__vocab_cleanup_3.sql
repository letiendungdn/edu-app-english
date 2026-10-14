-- Đợt dọn thứ ba khi viết lại câu ví dụ: số đếm ghép, từ chỉ dùng trong phim, từ mang tính miệt thị.
CREATE TABLE removed_words (word VARCHAR(255) PRIMARY KEY);
INSERT INTO removed_words (word) VALUES ('bumpkin'), ('d-day'), ('twenty-four');

DELETE FROM srs_cards
WHERE content_type = 'VOCABULARY'
  AND content_id IN (SELECT v.id FROM vocabulary v JOIN removed_words r ON LOWER(v.word) = r.word);
DELETE FROM dictation_attempts
WHERE vocab_id IN (SELECT v.id FROM vocabulary v JOIN removed_words r ON LOWER(v.word) = r.word);
DELETE FROM vocabulary WHERE LOWER(word) IN (SELECT word FROM removed_words);
DROP TABLE removed_words;
