-- DB作成
CREATE DATABASE db_dev; 

-- 作成したDBへ切り替え
\c db_dev

-- ロールの作成
CREATE ROLE dev WITH LOGIN PASSWORD 'root';

-- DB作成
CREATE DATABASE db_unittest; 

-- 作成したDBへ切り替え
\c db_unittest

-- ロールの作成
CREATE ROLE dev WITH LOGIN PASSWORD 'root';