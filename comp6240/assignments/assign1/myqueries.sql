-- name: Zhiren Lin
-- uid:  u7753813

-- Q1
SELECT COUNT(last_name) FROM person
  WHERE
  year_born > 1974 AND
  last_name LIKE '%e';

-- Q2
SELECT ROUND(AVG(run_time), 2) FROM
  (
    SELECT DISTINCT
    restriction.title,
    restriction.production_year,
    description,
    restriction.country,
    run_time
    FROM restriction, movie
    WHERE
    restriction.country = 'USA' AND
    restriction.description = 'R' AND
    restriction.production_year > 1991
  ) AS mv;

-- Q3
SELECT COUNT(crew_number) FROM
  (
    SELECT COUNT(id) AS crew_number, title FROM crew
    GROUP BY title
    HAVING COUNT(id) = 2
  ) AS cn;

-- Q4
SELECT id, first_name || ' ' || last_name AS full_name FROM -- director (id, name)
  (
    SELECT * FROM
    (
      SELECT * FROM director AS d -- director id without an award
      LEFT JOIN director_award AS da
      USING (title)
      WHERE RESULT IS NULL
    ) nad
    RIGHT JOIN person AS p        -- director (id, name, movie, year ...) without an award
    USING (id)
    WHERE NOT title IS NULL
  ) dnoa;

-- Q5
SELECT COUNT(id) AS num_of_movies, first_name, last_name FROM
  (
    SELECT * FROM
    (
      SELECT * FROM director          -- director(s) who have directed
      LEFT JOIN movie
      USING (title) WHERE major_genre = 'action'
    ) am
    LEFT JOIN person AS p
    USING (id)
  ) fi GROUP BY COUNT(id), first_name ORDER BY first_name;

-- Q6
SELECT
  ROUND(
    100.0 * COUNT(ca.title)/(select count(title) from movie where major_genre = 'comedy'),
    2
  ) AS "Aussie Comedy Prop. (%)"
  FROM
  (SELECT title FROM movie WHERE major_genre = 'comedy' AND country = 'Australia') ca;

-- Q7
WITH final AS (
  SELECT COUNT(title) AS total_won, title, production_year FROM
  (
    SELECT
    a.title, a.production_year, a.award_name AS dir_award, a.year_of_award AS dir_award_year,
    b.award_name AS act_award, b.year_of_award AS act_award_year, b.category
    FROM director_award a
    LEFT JOIN actor_award b
    USING(title, production_year)
    WHERE NOT description IS NULL
    ORDER BY title
  ) awards
  GROUP BY title, production_year
) SELECT title, production_year FROM final
  WHERE total_won = (SELECT MIN(total_won) FROM final);

-- Q8
SELECT COUNT(award_num) FROM
  (
    SELECT COUNT(title) AS award_num, title, production_year FROM
    (
      SELECT
      *
      FROM movie_award AS A
      FULL JOIN director_award
      USING (title, production_year, year_of_award)
      FULL JOIN writer_award
      USING (title, production_year, year_of_award)
      FULL JOIN actor_award
      USING (title, production_year, year_of_award)
      FULL JOIN crew_award
      USING (title, production_year, year_of_award)
      ORDER BY title
    ) awards
    GROUP BY title, production_year
    ORDER BY award_num;
  ) award_mv;

-- Q9
SELECT DISTINCT CONCAT('(', title, ', ', production_year, ')') AS pair FROM
  (
    SELECT
    *
    FROM movie_award AS A
    FULL JOIN director_award
    USING (title, production_year, year_of_award)
    FULL JOIN writer_award
    USING (title, production_year, year_of_award)
    FULL JOIN actor_award
    USING (title, production_year, year_of_award)
    FULL JOIN crew_award
    USING (title, production_year, year_of_award)
    ORDER BY title
  ) awards
  ORDER BY pair;

-- Q10
SELECT id, first_name, last_name
  FROM person
  RIGHT JOIN
  (
    SELECT id FROM writer WHERE credits <> ''
  ) AS coop
  USING(id)
  ORDER BY first_name;
