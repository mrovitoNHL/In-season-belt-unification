
CALL spBeltShares(20212022);

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