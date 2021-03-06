-- numbers all attempts in descending chronological order
SET @a = 0, @p = '', @e = '';
DROP TABLE IF EXISTS numbered;
CREATE TABLE numbered
(KEY number_pe (personId, eventId))
SELECT a.*, @a := IF(@p = CAST(personId AS CHAR) AND @e = CAST(eventId AS CHAR), @a + 1, 1) numbered, @p := CAST(personId AS CHAR) drop1, @e := CAST(eventId AS CHAR) drop2
FROM (SELECT id, personId, eventId, value FROM all_attempts ORDER BY personId, eventId, id DESC) a
ORDER BY personId, eventId, id DESC;

-- gets average of most recent 5 solves
SET @a = 0, @p = '', @e = '';
DROP TABLE IF EXISTS current_ao5;
CREATE TABLE current_ao5
SELECT personId, eventId, 
IF(SUM(CASE WHEN value = -1 THEN 1 END)>1,
-1,
(SUM(CASE WHEN value = -1 THEN 999999999999 ELSE value END)-MIN(CASE WHEN value = -1 THEN 999999999999 ELSE value END)-MAX(CASE WHEN value = -1 THEN 999999999999 ELSE value END))/3) ao5, 
GROUP_CONCAT(FORMAT_RESULT(value,eventId,'s') 
ORDER BY id SEPARATOR ", ") times 
FROM numbered
WHERE numbered <= 5 AND 
eventId NOT IN ('333mbf','333mbo','magic','mmagic','333ft') 
GROUP BY personId, eventId HAVING COUNT(*) >= 5;

-- as above
SET @a = 0, @p = '', @e = '';
DROP TABLE IF EXISTS current_ao12;
CREATE TABLE current_ao12
SELECT personId, eventId, IF(SUM(CASE WHEN value = -1 THEN 1 END)>1,-1,AVG(CASE WHEN ranked BETWEEN 2 AND 11 THEN value END)) ao12, GROUP_CONCAT(FORMAT_RESULT(value,eventId,'s') ORDER BY id SEPARATOR ", ") times
FROM (SELECT a.*, @a := IF(@p = CAST(personId AS CHAR) AND @e = eventId, @a + 1, 1) ranked, @p := CAST(personId AS CHAR) drop1, @e := eventId drop2
FROM (SELECT id, personId, eventId, value FROM numbered WHERE numbered <= 12 AND eventId NOT IN ('333mbf','333mbo','magic','mmagic','333ft') ORDER BY personId, eventId, (CASE WHEN value = -1 THEN 999999999999 ELSE value END)) a) b
GROUP BY personId, eventId HAVING COUNT(*) >= 12;

SET @a = 0, @p = '', @e = '';
DROP TABLE IF EXISTS current_ao25;
CREATE TABLE current_ao25
SELECT personId, eventId, IF(SUM(CASE WHEN value = -1 THEN 1 END)>2,-1,AVG(CASE WHEN ranked BETWEEN 3 AND 23 THEN value END)) ao25, GROUP_CONCAT(FORMAT_RESULT(value,eventId,'s') ORDER BY id SEPARATOR ", ") times
FROM (SELECT a.*, @a := IF(@p = CAST(personId AS CHAR) AND @e = eventId, @a + 1, 1) ranked, @p := CAST(personId AS CHAR) drop1, @e := eventId drop2
FROM (SELECT id, personId, eventId, value FROM numbered WHERE numbered <= 25 AND eventId NOT IN ('333mbf','333mbo','magic','mmagic','333ft') ORDER BY personId, eventId, (CASE WHEN value = -1 THEN 999999999999 ELSE value END)) a) b
GROUP BY personId, eventId HAVING COUNT(*) >= 25;

SET @a = 0, @p = '', @e = '';
DROP TABLE IF EXISTS current_ao50;
CREATE TABLE current_ao50
SELECT personId, eventId, IF(SUM(CASE WHEN value = -1 THEN 1 END)>3,-1,AVG(CASE WHEN ranked BETWEEN 4 AND 47 THEN value END)) ao50, GROUP_CONCAT(FORMAT_RESULT(value,eventId,'s') ORDER BY id SEPARATOR ", ") times
FROM (SELECT a.*, @a := IF(@p = CAST(personId AS CHAR) AND @e = eventId, @a + 1, 1) ranked, @p := CAST(personId AS CHAR) drop1, @e := eventId drop2
FROM (SELECT id, personId, eventId, value FROM numbered WHERE numbered <= 50 AND eventId NOT IN ('333mbf','333mbo','magic','mmagic','333ft') ORDER BY personId, eventId, (CASE WHEN value = -1 THEN 999999999999 ELSE value END)) a) b
GROUP BY personId, eventId HAVING COUNT(*) >= 50;

SET @a = 0, @p = '', @e = '';
DROP TABLE IF EXISTS current_ao100;
CREATE TABLE current_ao100
SELECT personId, eventId, IF(SUM(CASE WHEN value = -1 THEN 1 END)>5,-1,AVG(CASE WHEN ranked BETWEEN 6 AND 95 THEN value END)) ao100, GROUP_CONCAT(FORMAT_RESULT(value,eventId,'s') ORDER BY id SEPARATOR ", ") times
FROM (SELECT a.*, @a := IF(@p = CAST(personId AS CHAR) AND @e = eventId, @a + 1, 1) ranked, @p := CAST(personId AS CHAR) drop1, @e := eventId drop2
FROM (SELECT id, personId, eventId, value FROM numbered WHERE numbered <= 100 AND eventId NOT IN ('333mbf','333mbo','magic','mmagic','333ft') ORDER BY personId, eventId, (CASE WHEN value = -1 THEN 999999999999 ELSE value END)) a) b
GROUP BY personId, eventId HAVING COUNT(*) >= 100;
