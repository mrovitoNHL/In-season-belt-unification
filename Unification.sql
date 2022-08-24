-- Each team starts the season with one share of the belt
-- When two teams each with one or more shares play each other, the team that wins takes all shares

-- First, build a table

DELIMITER $$

DROP PROCEDURE IF EXISTS spBeltShares;
CREATE PROCEDURE spBeltShares(IN season int)
BEGIN

    DROP TABLE IF EXISTS beltShares;
    CREATE TABLE beltShares (
    season int,
    teamId int,
    recordDate date,
    shareChange int,
    PRIMARY KEY(season, teamId, recordDate)
    );

    SET @season = season;
    SET @teamsAlive = 999;
    SET @seqNumber = 0;

    -- Next, add one pre-season share for each team in the league for that season
    INSERT INTO beltShares
    SELECT ts.season, ts.teamId, DATE_ADD(DATE(startDate), INTERVAL -1 DAY) recordDate, 1 shareChange
    FROM season s
    INNER JOIN teamStats ts ON ts.season = s.seasonId AND ts.gameType = 2
    WHERE seasonId = @season;

    REPEAT

        -- Get the sequence number for the next game that had a winner that involved two teams that are still alive
        SET @seqNumber = 0;
        SET @seqNumber = (
            SELECT MIN(g.sequence_number)
            FROM teamByGameStats tbg
            INNER JOIN game g ON g.game_id = tbg.game_id
            INNER JOIN (
                        SELECT season, teamId, SUM(shareChange) shares, MAX(recordDate) recordDate
                        FROM beltShares
                        GROUP BY season, teamId
                        HAVING shares > 0
                       ) t ON t.teamId = tbg.teamId AND t.recordDate < tbg.game_date
            INNER JOIN (
                        SELECT season, teamId, SUM(shareChange) shares, MAX(recordDate) recordDate
                        FROM beltShares
                        GROUP BY season, teamId
                        HAVING shares > 0
                       ) o ON o.teamId = tbg.opponentTeamId AND o.recordDate < tbg.game_date
            WHERE 1 = 1
              AND tbg.gameType = 2
              AND tbg.season = @season
              AND tbg.decision ='W'
        ) ;

        -- Update winning team with losing team's shares
        INSERT INTO beltShares(season, teamId, recordDate, shareChange)
        SELECT tbg.season, tbg.teamId, tbg.game_date, q.shares
        FROM game g
        INNER JOIN teamByGameStats tbg ON tbg.game_id = g.game_id
        INNER JOIN (
                        SELECT season, teamId, SUM(shareChange) shares FROM beltshares GROUP BY season, teamId
                   ) q ON q.season = tbg.season AND q.teamId = tbg.opponentTeamId
        WHERE 1 = 1
          AND tbg.gameType = 2
          AND tbg.decision = 'W'
          AND g.sequence_number = @seqNumber
        ;

        -- Update losing team - they lose all shares
        INSERT INTO beltShares(season, teamId, recordDate, shareChange)
        SELECT tbg.season, tbg.opponentTeamId, tbg.game_date, q.shares
        FROM game g
        INNER JOIN teamByGameStats tbg ON tbg.game_id = g.game_id
        INNER JOIN (
                        SELECT season, teamId, -1 * SUM(shareChange) shares FROM beltshares GROUP BY season, teamId
                   ) q ON q.season = tbg.season AND q.teamId = tbg.opponentTeamId
        WHERE 1 = 1
          AND tbg.gameType = 2
          AND tbg.decision = 'W'
          AND g.sequence_number = @seqNumber
        ;

        -- Get the count of teams that are still alive
        /*
        SET @teamsAlive := (
            SELECT count(*) teamsAlive
            FROM (
                     SELECT season, teamId, SUM(shareChange) shares, MAX(recordDate) recordDate
                     FROM beltShares
                     GROUP BY season, teamId
                 ) q
            WHERE shares > 0
        );
         */

    until @seqNumber IS NULL end repeat;


END$$

DELIMITER ;