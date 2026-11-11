-- Day 29: 연속 구간 찾기 (Gaps and Islands)
-- 목표: ROW_NUMBER 와 LAG 를 이용해 "연속으로 이어진 구간"과 "빠진 구간"을 찾는다.

-- 개념 설명
-- 연속 출석, 연속 로그인, 연속 판매일 같은 문제를 "Gaps and Islands" 라고 부른다.
--   섬(island) : 값이 끊김 없이 이어지는 구간
--   틈(gap)    : 섬과 섬 사이에 빠진 구간
-- 핵심 아이디어 1) 연속된 값에서 ROW_NUMBER 를 빼면 같은 섬 안에서는 항상 같은 값이 나온다.
--   예) day 1,2,3 / rn 1,2,3 -> 차이 0,0,0     day 7,8 / rn 4,5 -> 차이 3,3
--   이 차이값을 그룹 키로 GROUP BY 하면 섬 하나가 한 그룹이 된다.
-- 핵심 아이디어 2) LAG 로 바로 앞 값을 가져와 차이가 1보다 크면 "틈"이 있다는 뜻이다.
-- 날짜 함수는 DB마다 달라서, 이번 예제는 날짜 대신 정수(일자 번호)로 연습한다.

DROP TABLE IF EXISTS attendance;

CREATE TABLE attendance (
    student VARCHAR(10) NOT NULL,
    day_no  INTEGER     NOT NULL   -- 출석한 날의 번호 (1~31)
);

INSERT INTO attendance (student, day_no) VALUES
    ('민수', 1), ('민수', 2), ('민수', 3), ('민수', 5), ('민수', 6), ('민수', 9),
    ('지은', 4), ('지은', 5), ('지은', 6), ('지은', 7),
    ('하준', 2), ('하준', 8), ('하준', 9);

-- 1) 학생별로 출석 순번(rn)과 "day_no - rn" 을 확인해 보기
SELECT student, day_no,
       ROW_NUMBER() OVER (PARTITION BY student ORDER BY day_no) AS rn,
       day_no - ROW_NUMBER() OVER (PARTITION BY student ORDER BY day_no) AS grp
FROM attendance
ORDER BY student, day_no;

-- 2) 연속 출석 구간(섬)별 시작일, 종료일, 연속 일수
WITH numbered AS (
    SELECT student, day_no,
           day_no - ROW_NUMBER() OVER (PARTITION BY student ORDER BY day_no) AS grp
    FROM attendance
)
SELECT student,
       MIN(day_no) AS start_day,
       MAX(day_no) AS end_day,
       COUNT(*)    AS streak_days
FROM numbered
GROUP BY student, grp
ORDER BY student, start_day;

-- 3) 학생별 최장 연속 출석 일수
WITH numbered AS (
    SELECT student, day_no,
           day_no - ROW_NUMBER() OVER (PARTITION BY student ORDER BY day_no) AS grp
    FROM attendance
),
streaks AS (
    SELECT student, grp, COUNT(*) AS streak_days
    FROM numbered
    GROUP BY student, grp
)
SELECT student, MAX(streak_days) AS longest_streak
FROM streaks
GROUP BY student
ORDER BY longest_streak DESC, student;

-- 4) LAG 로 빠진 구간(틈) 찾기: 바로 앞 출석일과 차이가 2 이상이면 그 사이가 결석
WITH with_prev AS (
    SELECT student, day_no,
           LAG(day_no) OVER (PARTITION BY student ORDER BY day_no) AS prev_day
    FROM attendance
)
SELECT student,
       prev_day + 1 AS absent_from,
       day_no - 1   AS absent_to
FROM with_prev
WHERE prev_day IS NOT NULL
  AND day_no - prev_day > 1
ORDER BY student, absent_from;

-- 연습 문제
-- 문제 1) 연속 출석이 3일 이상인 구간만 학생 이름, 시작일, 종료일과 함께 조회해 보세요. (힌트: 2번 쿼리에 HAVING COUNT(*) >= 3)
-- 문제 2) 모든 학생 중 "가장 긴 결석 기간(틈의 길이)"을 가진 학생과 그 길이를 구해 보세요. (힌트: 4번 쿼리의 day_no - prev_day - 1 에 MAX)
