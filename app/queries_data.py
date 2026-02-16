QUERIES = [
    {
        "id": 1,
        "title": "Total Voters Registered per Constituency",
        "sql": """
            SELECT c.Name AS Constituency, COUNT(v.VoterID) AS TotalVoters
            FROM Constituency c
            LEFT JOIN Voter v ON c.ConstituencyID = v.ConstituencyID
            GROUP BY c.ConstituencyID, c.Name;
        """
    },
    {
        "id": 2,
        "title": "Voter Turnout Percentage (Election 1)",
        "sql": """
            SELECT 
                c.Name AS Constituency,
                COUNT(vp.VoterID) AS VotesCast,
                (SELECT COUNT(*) FROM Voter WHERE ConstituencyID = c.ConstituencyID) AS TotalVoters,
                ROUND((COUNT(vp.VoterID) * 100.0 / (SELECT COUNT(*) FROM Voter WHERE ConstituencyID = c.ConstituencyID)), 2) AS TurnoutPct
            FROM Constituency c
            JOIN VoterParticipation vp ON c.ConstituencyID = vp.ConstituencyID
            WHERE vp.ElectionID = 1
            GROUP BY c.ConstituencyID, c.Name;
        """
    },
    {
        "id": 3,
        "title": "Booth-wise Voting Stats",
        "sql": """
            SELECT 
                b.BoothName, 
                c.Name AS Constituency, 
                COUNT(vp.VoterID) AS VotesRecorded
            FROM Booth b
            JOIN Constituency c ON b.ConstituencyID = c.ConstituencyID
            LEFT JOIN VoterParticipation vp ON b.BoothID = vp.BoothID AND vp.ElectionID = 1
            GROUP BY b.BoothID, b.BoothName, c.Name
            ORDER BY VotesRecorded DESC;
        """
    },
    {
        "id": 4,
        "title": "Total Votes per Party (Election 1)",
        "sql": """
            SELECT 
                pp.PartyName, 
                COUNT(v.VoteID) AS TotalVotes
            FROM PoliticalParty pp
            JOIN Candidate c ON pp.PartyID = c.PartyID
            JOIN Vote v ON c.CandidateID = v.CandidateID
            WHERE v.ElectionID = 1
            GROUP BY pp.PartyName
            ORDER BY TotalVotes DESC;
        """
    },
    {
        "id": 5,
        "title": "Rich Candidates (> 1 Crore Assets)",
        "sql": """
            SELECT c.Name, pp.PartyName, c.TotalAssets
            FROM Candidate c
            JOIN PoliticalParty pp ON c.PartyID = pp.PartyID
            WHERE c.TotalAssets > 10000000;
        """
    },
    {
        "id": 6,
        "title": "Independent Candidates",
        "sql": """
            SELECT Name, ConstituencyID, ElectionID
            FROM Candidate
            WHERE PartyID = (SELECT PartyID FROM PoliticalParty WHERE PartyName = 'Independent');
        """
    },
    {
        "id": 7,
        "title": "Rank Candidates by Votes (Window Function)",
        "sql": """
            SELECT 
                c.Name AS Constituency,
                cand.Name AS Candidate,
                COUNT(v.VoteID) AS Votes,
                DENSE_RANK() OVER (PARTITION BY c.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) AS `Rank`
            FROM Candidate cand
            JOIN Vote v ON cand.CandidateID = v.CandidateID
            JOIN Constituency c ON cand.ConstituencyID = c.ConstituencyID
            WHERE v.ElectionID = 1
            GROUP BY cand.CandidateID, c.ConstituencyID, c.Name, cand.Name;
        """
    },
    {
        "id": 8,
        "title": "Constituency Winners (Subquery)",
        "sql": """
            SELECT Constituency, Candidate, Votes
            FROM (
                SELECT 
                    c.Name AS Constituency,
                    cand.Name AS Candidate,
                    COUNT(v.VoteID) AS Votes,
                    RANK() OVER (PARTITION BY c.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) AS `Rank`
                FROM Candidate cand
                JOIN Vote v ON cand.CandidateID = v.CandidateID
                JOIN Constituency c ON cand.ConstituencyID = c.ConstituencyID
                WHERE v.ElectionID = 1
                GROUP BY cand.CandidateID, c.ConstituencyID, c.Name, cand.Name
            ) AS RankedResults
            WHERE `Rank` = 1;
        """
    },
    {
        "id": 9,
        "title": "Victory Margin Analysis",
        "sql": """
            WITH RankedVotes AS (
                SELECT 
                    c.Name AS Constituency,
                    cand.Name AS Candidate,
                    COUNT(v.VoteID) AS Votes,
                    ROW_NUMBER() OVER (PARTITION BY c.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) AS Position
                FROM Candidate cand
                JOIN Vote v ON cand.CandidateID = v.CandidateID
                JOIN Constituency c ON cand.ConstituencyID = c.ConstituencyID
                WHERE v.ElectionID = 1
                GROUP BY cand.CandidateID, c.ConstituencyID, c.Name, cand.Name
            )
            SELECT 
                r1.Constituency,
                r1.Candidate AS Winner,
                r1.Votes AS WinnerVotes,
                r2.Candidate AS RunnerUp,
                r2.Votes AS RunnerUpVotes,
                (r1.Votes - r2.Votes) AS Margin
            FROM RankedVotes r1
            JOIN RankedVotes r2 ON r1.Constituency = r2.Constituency
            WHERE r1.Position = 1 AND r2.Position = 2;
        """
    },
    {
        "id": 10,
        "title": "Gender Ratio per Constituency",
        "sql": """
            SELECT 
                c.Name,
                SUM(CASE WHEN v.Gender = 'Male' THEN 1 ELSE 0 END) AS MaleVoters,
                SUM(CASE WHEN v.Gender = 'Female' THEN 1 ELSE 0 END) AS FemaleVoters,
                ROUND(SUM(CASE WHEN v.Gender = 'Female' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN v.Gender = 'Male' THEN 1 ELSE 0 END), 0), 2) AS GenderRatio
            FROM Constituency c
            JOIN Voter v ON c.ConstituencyID = v.ConstituencyID
            GROUP BY c.Name;
        """
    },
    {
        "id": 11,
        "title": "Young Voters (18-25)",
        "sql": """
            SELECT 
                v.Name, 
                TIMESTAMPDIFF(YEAR, v.DOB, CURDATE()) AS Age, 
                c.Name AS Constituency
            FROM Voter v
            JOIN VoterParticipation vp ON v.VoterID = vp.VoterID
            JOIN Constituency c ON v.ConstituencyID = c.ConstituencyID
            WHERE TIMESTAMPDIFF(YEAR, v.DOB, CURDATE()) BETWEEN 18 AND 25;
        """
    },
    {
        "id": 12,
        "title": "Constituencies with 100% Turnout (Hypothetical)",
        "sql": """
            SELECT c.Name
            FROM Constituency c
            WHERE (SELECT COUNT(*) FROM Voter WHERE ConstituencyID = c.ConstituencyID) = 
                  (SELECT COUNT(*) FROM VoterParticipation WHERE ConstituencyID = c.ConstituencyID AND ElectionID = 1);
        """
    },
    {
        "id": 13,
        "title": "Biggest Loser (High Assets but Lost)",
        "sql": """
            WITH CandidateRanks AS (
                SELECT 
                    cand.CandidateID,
                    cand.Name,
                    cand.TotalAssets,
                    RANK() OVER (PARTITION BY cand.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) AS `Rank`
                FROM Candidate cand
                LEFT JOIN Vote v ON cand.CandidateID = v.CandidateID
                WHERE cand.ElectionID = 1
                GROUP BY cand.CandidateID, cand.Name, cand.TotalAssets, cand.ConstituencyID
            )
            SELECT Name, TotalAssets
            FROM CandidateRanks
            WHERE `Rank` > 1
            ORDER BY TotalAssets DESC
            LIMIT 1;
        """
    },
    {
        "id": 14,
        "title": "Party with Most Candidates",
        "sql": """
            SELECT pp.PartyName, COUNT(c.CandidateID) AS CandidatesFielded
            FROM PoliticalParty pp
            JOIN Candidate c ON pp.PartyID = c.PartyID
            WHERE c.ElectionID = 1
            GROUP BY pp.PartyName
            ORDER BY CandidatesFielded DESC
            LIMIT 1;
        """
    },
    {
        "id": 15,
        "title": "Average Voter Age",
        "sql": """
            SELECT 
                c.Name, 
                ROUND(AVG(TIMESTAMPDIFF(YEAR, v.DOB, CURDATE())), 1) AS AvgAge
            FROM Constituency c
            JOIN Voter v ON c.ConstituencyID = v.ConstituencyID
            GROUP BY c.Name;
        """
    },
    {
        "id": 16,
        "title": "Double Voting Attempts (Audit)",
        "sql": """
            SELECT VoterID, COUNT(*) 
            FROM VoterParticipation 
            GROUP BY VoterID, ElectionID 
            HAVING COUNT(*) > 1;
        """
    },
    {
        "id": 17,
        "title": "Voters Who Did Not Vote",
        "sql": """
            SELECT v.Name, v.EPIC_Number
            FROM Voter v
            WHERE v.VoterID NOT IN (
                SELECT VoterID FROM VoterParticipation WHERE ElectionID = 1
            );
        """
    },
    {
        "id": 18,
        "title": "Pending Complaints",
        "sql": """
            SELECT c.Description, v.Name AS Complainant, e.Title AS Election
            FROM Complaint c
            JOIN Voter v ON c.VoterID = v.VoterID
            JOIN Election e ON c.ElectionID = e.ElectionID
            WHERE c.Status = 'Pending';
        """
    },
    {
        "id": 19,
        "title": "Turnout: Urban vs Rural",
        "sql": """
            SELECT 
                c.Type,
                COUNT(vp.VoterID) AS TotalVotes
            FROM Constituency c
            JOIN VoterParticipation vp ON c.ConstituencyID = vp.ConstituencyID
            WHERE vp.ElectionID = 1
            GROUP BY c.Type;
        """
    },
    {
        "id": 20,
        "title": "Candidate Vote Share %",
        "sql": """
            SELECT 
                cand.Name,
                COUNT(v.VoteID) AS VotesReceived,
                (SELECT COUNT(*) FROM Vote WHERE ElectionID = 1 AND ConstituencyID = cand.ConstituencyID) AS TotalConstituencyVotes,
                ROUND((COUNT(v.VoteID) * 100.0 / (SELECT COUNT(*) FROM Vote WHERE ElectionID = 1 AND ConstituencyID = cand.ConstituencyID)), 2) AS VoteSharePct
            FROM Candidate cand
            JOIN Vote v ON cand.CandidateID = v.CandidateID
            WHERE cand.ElectionID = 1
            GROUP BY cand.CandidateID, cand.Name, cand.ConstituencyID;
        """
    }
]
