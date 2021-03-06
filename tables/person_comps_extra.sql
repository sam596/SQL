DROP TABLE IF EXISTS person_comps_extra;
SET @p = NULL, @c = 0, @dd = NULL, @d = NULL;
CREATE TABLE person_comps_extra
SELECT a.*,
	@c := IF(a.personId = @p,@c+1,1) 'compNumber',
	@dd := IF(a.personId = @p,DATEDIFF(a.date,@d),NULL) 'daysLastComp',
	@p := a.personId 'drop1',
	@d := a.date 'drop2'
FROM
	(SELECT a.*, IFNULL(b.PRs,0) 'PRs', IFNULL(b.singlePRs,0) 'singlePRs', IFNULL(b.averagePRs,0) 'averagePRs', c.latitude, c.longitude
	FROM
		(SELECT personId, personName, personCountryId, personContinentId, competitionId, compCityName, compCountryId, compContinentId, date, weekend,
				COUNT(DISTINCT eventId) 'eventsAttempted',
				COUNT(DISTINCT (CASE WHEN best > 0 THEN eventId END)) 'eventsSucceeded',
				COUNT(DISTINCT (CASE WHEN eventId NOT IN ('magic','mmagic','333mbo','333ft') THEN eventId END)) 'currentEventsAttempted',
				COUNT(DISTINCT (CASE WHEN best > 0 AND eventId NOT IN ('magic','mmagic','333mbo','333ft') THEN eventId END)) 'currentEventsSucceeded',
				COUNT(DISTINCT (CASE WHEN average > 0 AND eventId NOT IN ('444bf','555bf','magic','mmagic','333mbo') THEN eventId END)) 'eventsAverage',
				COUNT(DISTINCT (CASE WHEN average > 0 AND eventId IN ('444bf','555bf') THEN eventId END)) 'bigBldAverage',
				COUNT(DISTINCT (CASE WHEN eventId IN ('magic','mmagic','333mbo','333ft') THEN eventId END)) 'oldEventsAttempted',
				COUNT(DISTINCT (CASE WHEN best > 0 AND eventId IN ('magic','mmagic','333mbo','333ft') THEN eventId END)) 'oldEventsSucceeded',
				COUNT(DISTINCT (CASE WHEN average > 0 AND eventId IN ('magic','mmagic','333ft') THEN eventId END)) 'oldEventsAverage',
				COUNT(CASE WHEN value1 NOT IN (0,-2) THEN 1 END)+COUNT(CASE WHEN value2 NOT IN (0,-2) THEN 1 END)+COUNT(CASE WHEN value3 NOT IN (0,-2) THEN 1 END)+COUNT(CASE WHEN value4 NOT IN (0,-2) THEN 1 END)+COUNT(CASE WHEN value5 NOT IN (0,-2) THEN 1 END) 'attempts',
				COUNT(CASE WHEN value1 > 0 THEN 1 END)+COUNT(CASE WHEN value2 > 0 THEN 1 END)+COUNT(CASE WHEN value3 > 0 THEN 1 END)+COUNT(CASE WHEN value4 > 0 THEN 1 END)+COUNT(CASE WHEN value5 > 0 THEN 1 END) 'completedSolves',
				COUNT(CASE WHEN value1 = -1 THEN 1 END)+COUNT(CASE WHEN value2 = -1 THEN 1 END)+COUNT(CASE WHEN value3 = -1 THEN 1 END)+COUNT(CASE WHEN value4 = -1 THEN 1 END)+COUNT(CASE WHEN value5 = -1 THEN 1 END) 'DNFs',
				COUNT(CASE WHEN roundTypeId IN ('c','f') THEN 1 END) 'finals',
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos <= 3 AND best > 0 THEN 1 END) 'podiums',
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 1 AND best > 0 THEN 1 END) 'gold',
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 2 AND best > 0 THEN 1 END) 'silver',
				COUNT(CASE WHEN roundTypeId IN ('c','f') AND pos = 3 AND best > 0 THEN 1 END) 'bronze',
				COUNT(CASE WHEN regionalSingleRecord != '' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord != '' THEN 1 END) 'records',
				COUNT(CASE WHEN regionalSingleRecord = 'WR' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord = 'WR' THEN 1 END) 'WRs',
				COUNT(CASE WHEN regionalSingleRecord NOT IN ('','NR','WR') THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord NOT IN ('','NR','WR') THEN 1 END) 'CRs',
				COUNT(CASE WHEN regionalSingleRecord = 'NR' THEN 1 END)+COUNT(CASE WHEN regionalAverageRecord = 'NR' THEN 1 END) 'NRs',
				MIN(CASE WHEN best > 0 THEN pos END) 'bestPos',
				MAX(pos) 'worstPos',
				GROUP_CONCAT(DISTINCT eventId ORDER BY eventId) 'events'
		FROM results_extra r
		GROUP BY personId, competitionId) a
	LEFT JOIN
		(SELECT personId, competitionId, COUNT(*) 'PRs', COUNT(CASE WHEN format = 's' THEN 1 END) 'singlePRs', COUNT(CASE WHEN format = 'a' THEN 1 END) 'averagePRs'
		FROM prs
		GROUP BY personId, competitionId) b
	ON a.personId = b.personId AND a.competitionId = b.competitionId
	JOIN
		competitions_extra c
	ON a.competitionId = c.id
	ORDER BY a.personId, date, a.competitionId) a;

ALTER TABLE person_comps_extra DROP drop1, DROP drop2;

SET @c = 1, @p = '', @fc = '', @dm = 1;
DROP TABLE IF EXISTS monthly_streak;
CREATE TABLE monthly_streak
(SELECT personId, personName, competitionId, datemonth,
    @c := IF(@p = personId AND @dm = datemonth - 1, @c + 1, 1) streak,
    @fc := IF(@p = personId AND @dm = datemonth - 1, @fc, competitionId) firstComp,
    @p := personId,
    @dm := datemonth
FROM
    (SELECT personId, personName, competitionId, datemonth FROM (SELECT personId, personName, competitionId, ((YEAR(startdate)-1970)*12)+MONTH(startdate) datemonth FROM person_comps_extra pce JOIN competitions_extra ce ON pce.competitionId = ce.id UNION ALL SELECT personId, personName, competitionId, ((YEAR(enddate)-1970)*12)+MONTH(enddate) datemonth  FROM person_comps_extra pce JOIN competitions_extra ce ON pce.competitionId = ce.id ORDER BY personId, datemonth) a GROUP BY personId, datemonth ORDER BY personId, datemonth) b
    );