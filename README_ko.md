# Book Tracker — PHP/SQL 애널리틱스

이 프로젝트의 핵심은 `bookinsert` 테이블을 대상으로 한 **SQL 쿼리와 리포트**입니다.  
PHP는 입력/출력과 Chart.js 시각화를 위한 **얇은 레이어**로만 사용됩니다.

> 영어 README가 필요하면 `README.md`를, 러시아어는 `README_RU.md`를 참고하세요.

---

## 리포지토리 구성
- `index.php` — 도서 입력 폼
- `output_list.php` — 도서 목록(기본 테이블)
- `book_edit.php` — 기존 레코드 수정 *(작업 중)*
- `stats.php` — 차트 페이지(Chart.js, DB에서 직접 조회)
- `check.js` — 폼 클라이언트 검증
- `analytics.sql` — 기본 분석용 SQL 쿼리(뷰 포함)
- `README.md` / `README_ko.md` — 문서

---

## 요구 사항
- XAMPP(php 8.x + MariaDB/MySQL), phpMyAdmin
- `bookinsert` 테이블이 이미 존재하고 데이터가 입력되고 있어야 합니다  
  > 예시의 DB 이름이 다르면 코드의 DB 이름만 바꿔 주세요.

---

## 빠른 시작

1) DB 연결 확인
스크립트에서 다음과 같이 연결합니다. 필요 시 비밀번호/DB명을 수정하세요.
```php
new mysqli('localhost', 'root', '1234', 'booktracker');

2) 분석 SQL 가져오기
analytics.sql을 사용 중인 데이터베이스로 가져옵니다.
phpMyAdmin: DB 선택 → Import → analytics.sql 선택 → Go
명령줄(CLI): "C:\xampp\mysql\bin\mysql.exe" -u root -p your_db < "C:\Path\analytics.sql"

3) 동작 확인
http://localhost/index.php — 레코드 입력
http://localhost/output_list.php — 목록 보기
http://localhost/stats.php — 차트 보기

stats.php에서 제공하는 차트 (작업 계속 중)
Monthly activity — 월별 책 권수 / 페이지 수 / 평균 페이지
Top authors — 가장 많이 읽은 저자 Top N
Genre breakdown — 장르 분포(genre 필드를 CSV로 저장)

## 데이터 및 가정

장르는 Fantasy, Romance 처럼 쉼표로 구분된 문자열(CSV) 로 저장합니다.
기본 리포트에는 충분합니다.
중복 방지는 JS(클라이언트)에서 체크합니다.
필요 시 DB에서 대소문자 무시 고유 제약(*_norm)을 추가할 수 있으나, 실행에 필수는 아닙니다.

##  기능
도서 입력 항목:
독자명(reader)
도서명(title)
저자(author)
장르(genre)
페이지 수(pages)
완독일(finished_date)

## 기술 스택
PHP 8.x
MySQL/MariaDB(XAMPP)
phpMyAdmin
JavaScript / Chart.js

 -- 데이터베이스 구조 (예시) --
 참고: MariaDB 버전에 따라 생성 열(GENERATED COLUMN) 제약이 다릅니다.
생성 열에 NOT NULL을 허용하지 않는 버전(예: MariaDB 10.4.x)이 있으니, 해당 경우 NOT NULL을 빼고 사용하세요.

CREATE DATABASE booktracker CHARACTER SET utf8mb4;
USE booktracker;

CREATE TABLE bookinsert (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  reader        VARCHAR(50)  NOT NULL,
  title         VARCHAR(100) NOT NULL,
  author        VARCHAR(100) NULL,
  pages         SMALLINT UNSIGNED NOT NULL,
  finished_date DATE         NULL,
  added_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  genre         VARCHAR(255) NULL,

  -- 생성 열(정규화: 공백 제거/소문자화는 필요 시 TRIM/LOWER 조합으로)
  title_norm    VARCHAR(255) GENERATED ALWAYS AS (LOWER(title))  STORED,
  reader_norm   VARCHAR(255) GENERATED ALWAYS AS (LOWER(reader)) STORED,

  UNIQUE KEY uniq_title_norm (title_norm),
  UNIQUE KEY uniq_reader_norm (reader_norm)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

## 문제 해결(간단)
Access denied/비밀번호 문제: 코드와 phpMyAdmin의 계정/비밀번호를 일치시키세요.
3306 포트 점유: 다른 MySQL 인스턴스를 종료하고 XAMPP의 MySQL을 재시작하세요.
차트가 안 보임: DB에 데이터가 있는지, 그리고 Chart.js CDN 접근이 되는지 확인하세요.

!!!
프로젝트는 학습 목적이며 계속 발전시킬 수 있습니다.
필요하다면 한국어/영어 README를 함께 유지하고, 코드/컬럼명/커밋 메시지는 영어를 권장합니다.
