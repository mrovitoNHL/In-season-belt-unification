# In-season-belt-unification
Single-season belt unification

This code is designed to follow a hypothetical belt-unification series.  Imagine that, at the beginning of each regular season, each team has one share of that hypothetical championship belt.  For each game between two teams with at least one share apiece, the team that wins gains control of all of the losing team's shares.  The losing team is then out of contention for the unified belt.  Ties are discounted.

The stored procedure creates a table called beltShares which holds records for each game where shares changed hands for the season in question.  It creates one record per game per team with the season, teamId, game date, and the change in shares resultant from that game for that team.

Unification.sql creates a stored procedure called spBeltShares(season). 

Usage:

-- Run the unification for a single season
CALL spBeltShares(20212022);

-- See the results of the beltShares table
SELECT * FROM beltShares;

-- List of teams that still have at least one share
SELECT season, t.team_abbrev team, SUM(shareChange) shares, MAX(recordDate) recordDate
FROM beltShares b
INNER JOIN advstats_team t ON t.team_id = b.teamId
GROUP BY season, teamId
HAVING shares > 0
;

-- List of games in which each team was eliminated
SELECT b.season, t.team_abbrev team, o.team_abbrev opp, b.recordDate, ABS(shareChange) sharesHeld, tbg.game_id
     , concat(v.TEAM_ABBREV, ': ', g.VISITINGSCORE, ' @ ', h.TEAM_ABBREV, ': ', g.HOMESCORE
              , CASE WHEN g.overtime IS NULL OR g.overtime = '' THEN ''
                     WHEN g.overtime = 'SO' THEN CONCAT(' ', g.overtime)
                     ELSE CONCAT(' ', CASE WHEN g.period = 4 THEN '' ELSE g.period - 3 END, g.overtime)
                END
             ) as Score
FROM beltShares b
INNER JOIN teamByGameStats tbg ON tbg.game_date = b.recordDate AND tbg.teamId = b.teamId
INNER JOIN game g ON g.game_id = tbg.game_id
INNER JOIN advstats_team h ON h.team_id = g.homeTeamId
INNER JOIN advstats_team v ON v.team_id = g.visitingTeamId
INNER JOIN advstats_team t ON t.team_id = tbg.teamId
INNER JOIN advstats_team o ON o.team_id = tbg.opponentTeamId
WHERE 1 = 1
  AND tbg.decision <> 'W'
ORDER BY g.sequence_number
;


-- List of games in which each team gained shares
SELECT b.season, t.team_abbrev team, o.team_abbrev opp, b.recordDate, ABS(shareChange) sharesGained, tbg.game_id
     , concat(v.TEAM_ABBREV, ': ', g.VISITINGSCORE, ' @ ', h.TEAM_ABBREV, ': ', g.HOMESCORE
              , CASE WHEN g.overtime IS NULL OR g.overtime = '' THEN ''
                     WHEN g.overtime = 'SO' THEN CONCAT(' ', g.overtime)
                     ELSE CONCAT(' ', CASE WHEN g.period = 4 THEN '' ELSE g.period - 3 END, g.overtime)
                END
             ) as Score
FROM beltShares b
INNER JOIN teamByGameStats tbg ON tbg.game_date = b.recordDate AND tbg.teamId = b.teamId
INNER JOIN game g ON g.game_id = tbg.game_id
INNER JOIN advstats_team h ON h.team_id = g.homeTeamId
INNER JOIN advstats_team v ON v.team_id = g.visitingTeamId
INNER JOIN advstats_team t ON t.team_id = tbg.teamId
INNER JOIN advstats_team o ON o.team_id = tbg.opponentTeamId
WHERE 1 = 1
  AND tbg.decision = 'W'
ORDER BY g.sequence_number
;
