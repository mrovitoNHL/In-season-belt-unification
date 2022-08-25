# In-season-belt-unification
Single-season belt unification

This code is designed to follow a hypothetical belt-unification series.  Imagine that, at the beginning of each regular season, each team has one share of that hypothetical championship belt.  For each game between two teams with at least one share apiece, the team that wins gains control of all of the losing team's shares.  The losing team is then out of contention for the unified belt.  Ties are not counted.

The stored procedure creates a table called beltShares which holds records for each game where shares changed hands for the season in question.  It creates one record per game per team with the season, teamId, game date, and the change in shares resultant from that game for that team.

Unification.sql creates a stored procedure called spBeltShares(<i>season</i>). 

Usage guidelines provided in Unification usage.sql
