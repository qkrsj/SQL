-- Day 31: 숫자 계산과 형변환 (ROUND, ABS, 나머지 %, 정수 나눗셈 함정)
-- 목표: 숫자 컬럼을 계산할 때 자주 쓰는 함수와, 나눗셈에서 생기는 실수를 막는 방법을 익힌다.

-- 개념 설명
--   ROUND(값, 자리수) : 반올림한다. ROUND(3.14159, 2) -> 3.14
--   ABS(값)           : 절댓값. 부호를 떼고 "차이의 크기"만 볼 때 쓴다.
--   a % b             : a 를 b 로 나눈 나머지. 짝수/홀수, 배수 판별에 쓴다.
--   * 1.0             : 정수끼리 나누면 SQLite 는 소수점을 버린다 (7 / 2 = 3).
--                       한쪽에 1.0 을 곱하면 실수 나눗셈이 된다 (7 * 1.0 / 2 = 3.5).
--   CAST(값 AS 타입)  : 값을 다른 타입으로 바꾼다. 문자열 '123' 을 숫자로 바꿀 때도 쓴다.
-- 참고: MySQL 은 정수 / 정수 도 소수로 계산해 주지만, SQLite 는 정수로 버린다.
--       두 DB 에서 같은 결과를 얻으려면 * 1.0 을 습관처럼 붙이는 것이 안전하다.

DROP TABLE IF EXISTS exam_scores;

CREATE TABLE exam_scores (
    id       INTEGER PRIMARY KEY,
    student  VARCHAR(10) NOT NULL,
    target   INTEGER NOT NULL,   -- 목표 점수
    score    INTEGER NOT NULL,   -- 실제 점수
    attempts INTEGER NOT NULL    -- 응시 횟수
);

INSERT INTO exam_scores (id, student, target, score, attempts) VALUES
    (1, '민수', 80, 73, 3),
    (2, '지은', 80, 91, 2),
    (3, '하준', 70, 70, 1),
    (4, '서연', 90, 85, 4),
    (5, '도윤', 60, 77, 3);

-- 1) 정수 나눗셈의 함정 : 점수 / 응시 횟수
--    avg_wrong 은 소수점이 버려지고, avg_right 는 소수점까지 나온다.
SELECT student,
       score / attempts         AS avg_wrong,
       score * 1.0 / attempts   AS avg_right
FROM exam_scores;

-- 2) ROUND 로 보기 좋게 정리 : 소수 첫째 자리까지
SELECT student,
       ROUND(score * 1.0 / attempts, 1) AS avg_per_try
FROM exam_scores
ORDER BY avg_per_try DESC;

-- 3) 목표 달성률(%) : 실제 점수 / 목표 점수 * 100
SELECT student,
       target,
       score,
       ROUND(score * 100.0 / target, 1) AS achievement_pct
FROM exam_scores
ORDER BY achievement_pct DESC;

-- 4) ABS : 목표와의 차이 크기 (부족하든 넘치든 거리만 본다)
SELECT student,
       score - target      AS diff,
       ABS(score - target) AS gap
FROM exam_scores
ORDER BY gap DESC;

-- 5) 나머지 % : 응시 횟수가 홀수인 학생만
SELECT student, attempts
FROM exam_scores
WHERE attempts % 2 = 1;

-- 6) CAST : 실수를 정수로, 문자열을 숫자로
--    CAST(2.9 AS INTEGER) 는 반올림이 아니라 소수점을 "버려서" 2 가 된다.
SELECT CAST(2.9 AS INTEGER)  AS cut_off,
       ROUND(2.9)            AS rounded,
       CAST('123' AS INTEGER) + 1 AS from_text;

-- 7) 집계와 함께 : 전체 평균 달성률 (소수 둘째 자리)
SELECT ROUND(AVG(score * 100.0 / target), 2) AS avg_achievement_pct
FROM exam_scores;

-- 연습 문제
-- 1) 목표 점수를 넘긴 학생(score > target)만 골라, 초과한 점수와 달성률(%)을
--    소수 첫째 자리까지 보여주세요. 달성률이 높은 순으로 정렬합니다.
-- 2) 점수가 목표보다 5점 이상 차이 나는 학생(부족하든 넘치든)의 이름과
--    차이의 크기를 ABS 로 구해서 보여주세요.
