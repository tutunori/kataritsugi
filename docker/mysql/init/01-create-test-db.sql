-- 開発用 Docker MySQL 初回起動時に test DB も作る
CREATE DATABASE IF NOT EXISTS kataritsugi_test CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON kataritsugi_test.* TO 'kataritsugi'@'%';
FLUSH PRIVILEGES;
