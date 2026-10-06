-- TEXT trên Postgres và VARCHAR không giới hạn là như nhau, nhưng H2 (chế độ PostgreSQL) đọc TEXT thành CLOB
-- nên Hibernate validate báo sai kiểu. Dùng VARCHAR không độ dài cho mọi cột văn bản dài để một bộ migration
-- chạy được trên cả hai.
ALTER TABLE grammar_lessons ALTER COLUMN explanation SET DATA TYPE VARCHAR;
ALTER TABLE reading_passages ALTER COLUMN content SET DATA TYPE VARCHAR;
ALTER TABLE listening_tracks ALTER COLUMN transcript SET DATA TYPE VARCHAR;
