QUERY_HIERARCHY = [
    {
        "id": "voter_analytics",
        "name": "Voter Analytics & Demographics",
        "subs": [
            {
                "id": "age_sub",
                "name": "Age-Based Analysis",
                "queries": [
                    {"id": 1, "title": "Avg Voter Age per Constituency", "sql": "SELECT c.Name, AVG(TIMESTAMPDIFF(YEAR, v.DOB, CURDATE())) as AvgAge FROM Constituency c JOIN Voter v ON c.ConstituencyID=v.ConstituencyID GROUP BY c.Name;"},
                    {"id": 2, "title": "Youth Census (18-25)", "sql": "SELECT c.Name, COUNT(*) FROM Voter v JOIN Constituency c ON v.ConstituencyID=c.ConstituencyID WHERE TIMESTAMPDIFF(YEAR, v.DOB, CURDATE()) BETWEEN 18 AND 25 GROUP BY c.Name;"},
                    {"id": 3, "title": "Senior Citizens (60+)", "sql": "SELECT c.Name, COUNT(*) FROM Voter v JOIN Constituency c ON v.ConstituencyID=c.ConstituencyID WHERE TIMESTAMPDIFF(YEAR, v.DOB, CURDATE()) >= 60 GROUP BY c.Name;"},
                    {"id": 4, "title": "Generation Split (Gen Z vs Millennial/GenX vs Senior)", "sql": "SELECT CASE WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) < 25 THEN 'Gen Z' WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 25 AND 60 THEN 'Millennial/GenX' ELSE 'Senior' END AS Demographic, COUNT(*) FROM Voter GROUP BY Demographic;"}
                ]
            },
            {
                "id": "gender_sub",
                "name": "Gender Dynamics",
                "queries": [
                    {"id": 5, "title": "Gender Ratio by Area", "sql": "SELECT c.Name, ROUND(SUM(CASE WHEN v.Gender='Female' THEN 1 ELSE 0 END)/NULLIF(SUM(CASE WHEN v.Gender='Male' THEN 1 ELSE 0 END),0), 2) as GenderRatio FROM Constituency c JOIN Voter v ON c.ConstituencyID=v.ConstituencyID GROUP BY c.Name;"},
                    {"id": 6, "title": "Female Voter Turnout %", "sql": "SELECT c.Name, (SELECT COUNT(*) FROM VoterParticipation vp JOIN Voter v2 ON vp.VoterID=v2.VoterID WHERE v2.Gender='Female' AND vp.ConstituencyID=c.ConstituencyID) * 100 / NULLIF((SELECT COUNT(*) FROM Voter v3 WHERE v3.Gender='Female' AND v3.ConstituencyID=c.ConstituencyID), 0) as femaleturnout FROM Constituency c;"},
                    {"id": 7, "title": "Male Participant Count", "sql": "SELECT c.Name, COUNT(vp.ParticipationID) FROM Constituency c JOIN VoterParticipation vp ON c.ConstituencyID=vp.ConstituencyID JOIN Voter v ON vp.VoterID=v.VoterID WHERE v.Gender='Male' GROUP BY c.Name;"}
                ]
            },
            {
                "id": "reg_sub",
                "name": "Registration Trends",
                "queries": [
                    {"id": 8, "title": "Monthly Registration Spike", "sql": "SELECT DATE_FORMAT(RegistrationDate, '%Y-%m') as Month, COUNT(*) as Count FROM Voter GROUP BY Month ORDER BY Count DESC;"},
                    {"id": 9, "title": "Daily Enrollment Heatmap", "sql": "SELECT RegistrationDate, COUNT(*) as Count FROM Voter GROUP BY RegistrationDate;"},
                    {"id": 10, "title": "Registrations in Last 30 Days", "sql": "SELECT Name, EPIC_Number FROM Voter WHERE RegistrationDate > DATE_SUB(CURDATE(), INTERVAL 30 DAY);"}
                ]
            },
            {
                "id": "geo_sub",
                "name": "Geographic Spread",
                "queries": [
                    {"id": 11, "title": "Voters per State Total", "sql": "SELECT State, COUNT(*) FROM Constituency c JOIN Voter v ON c.ConstituencyID=v.ConstituencyID GROUP BY State;"},
                    {"id": 12, "title": "Constituency Density (Voters per Con)", "sql": "SELECT State, COUNT(v.VoterID)/COUNT(DISTINCT c.ConstituencyID) FROM Constituency c JOIN Voter v ON c.ConstituencyID=v.ConstituencyID GROUP BY State;"},
                    {"id": 13, "title": "Urban vs Rural Population", "sql": "SELECT Type, COUNT(*) FROM Constituency c JOIN Voter v ON c.ConstituencyID=v.ConstituencyID GROUP BY Type;"}
                ]
            },
            {
                "id": "turnout_sub",
                "name": "Participation Patterns",
                "queries": [
                    {"id": 14, "title": "Election-wise Total Participation", "sql": "SELECT e.Title, COUNT(vp.ParticipationID) as Votes FROM Election e JOIN VoterParticipation vp ON e.ElectionID=vp.ElectionID GROUP BY e.ElectionID, e.Title;"},
                    {"id": 15, "title": "Constituency Participation (Per Election)", "sql": "SELECT c.Name, e.Title, COUNT(vp.ParticipationID) as Votes FROM Constituency c JOIN VoterParticipation vp ON c.ConstituencyID=vp.ConstituencyID JOIN Election e ON vp.ElectionID=e.ElectionID GROUP BY c.Name, e.ElectionID, e.Title ORDER BY Votes DESC;"}
                ]
            },
            {
                "id": "consistency_sub",
                "name": "Voter Loyalty",
                "queries": [
                    {"id": 16, "title": "Voters Participated in ALL Elections", "sql": "SELECT Name, EPIC_Number FROM Voter v WHERE (SELECT COUNT(DISTINCT ElectionID) FROM VoterParticipation WHERE VoterID=v.VoterID) = (SELECT COUNT(*) FROM Election);"},
                    {"id": 17, "title": "Zero-Turnout Voters List", "sql": "SELECT Name, EPIC_Number FROM Voter WHERE VoterID NOT IN (SELECT DISTINCT VoterID FROM VoterParticipation);"}
                ]
            },
            {
                "id": "audit_sub",
                "name": "Registry Audit",
                "queries": [
                    {"id": 18, "title": "Duplicate Name Check", "sql": "SELECT Name, COUNT(*) FROM Voter GROUP BY Name HAVING COUNT(*) > 1;"},
                    {"id": 19, "title": "Incomplete Address Records", "sql": "SELECT Name, EPIC_Number FROM Voter WHERE Address IS NULL OR LENGTH(Address) < 5;"}
                ]
            }
        ]
    },
    {
        "id": "election_intel",
        "name": "Election & Party Analytics",
        "subs": [
            {
                "id": "wins_sub",
                "name": "Winning Statistics",
                "queries": [
                    {"id": 20, "title": "General Election 2024 Winners", "sql": "SELECT * FROM (SELECT c.Name as Con, can.Name as Win, COUNT(v.VoteID) as Votes, RANK() OVER(PARTITION BY c.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) as r FROM Candidate can JOIN Vote v ON can.CandidateID=v.CandidateID JOIN Constituency c ON can.ConstituencyID=c.ConstituencyID WHERE v.ElectionID=2 GROUP BY can.CandidateID, c.ConstituencyID, can.Name, c.Name) T WHERE r=1;"},
                    {"id": 21, "title": "Party Seat Tally (Election 2)", "sql": "SELECT pp.PartyName, COUNT(*) as Seats FROM PoliticalParty pp JOIN Candidate can ON pp.PartyID=can.PartyID JOIN (SELECT ConstituencyID, CandidateID FROM (SELECT ConstituencyID, CandidateID, RANK() OVER(PARTITION BY ConstituencyID ORDER BY COUNT(VoteID) DESC) as r FROM Vote WHERE ElectionID=2 GROUP BY ConstituencyID, CandidateID) W WHERE r=1) Win ON can.CandidateID=Win.CandidateID GROUP BY pp.PartyName ORDER BY Seats DESC;"}
                ]
            },
            {
                "id": "perf_sub",
                "name": "Party Metrics",
                "queries": [
                    {"id": 22, "title": "Total Votes per Party (Overall)", "sql": "SELECT p.PartyName, COUNT(v.VoteID) as Votes FROM PoliticalParty p JOIN Candidate c ON p.PartyID=c.PartyID JOIN Vote v ON c.CandidateID=v.CandidateID GROUP BY p.PartyName ORDER BY Votes DESC;"},
                    {"id": 23, "title": "Vote Share %", "sql": "SELECT p.PartyName, COUNT(v.VoteID) * 100 / (SELECT COUNT(*) FROM Vote) as SharePct FROM PoliticalParty p JOIN Candidate c ON p.PartyID=c.PartyID LEFT JOIN Vote v ON c.CandidateID=v.CandidateID GROUP BY p.PartyName;"}
                ]
            },
            {
                "id": "margin_sub",
                "name": "Margin Analytics",
                "queries": [
                    {"id": 24, "title": "Closest Victories (Margin < 50)", "sql": "SELECT * FROM (SELECT r1.Con, (r1.V - r2.V) as Margin FROM (SELECT c.Name as Con, COUNT(v.VoteID) as V, ROW_NUMBER() OVER(PARTITION BY c.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) as r FROM Candidate can JOIN Vote v ON can.CandidateID=v.CandidateID JOIN Constituency c ON can.ConstituencyID=c.ConstituencyID GROUP BY can.CandidateID, c.ConstituencyID, c.Name) r1 JOIN (SELECT c.Name as Con, COUNT(v.VoteID) as V, ROW_NUMBER() OVER(PARTITION BY c.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) as r FROM Candidate can JOIN Vote v ON can.CandidateID=v.CandidateID JOIN Constituency c ON can.ConstituencyID=c.ConstituencyID GROUP BY can.CandidateID, c.ConstituencyID, c.Name) r2 ON r1.Con = r2.Con WHERE r1.r=1 AND r2.r=2) M WHERE Margin < 50;"},
                    {"id": 25, "title": "Highest Win Margins", "sql": "SELECT * FROM (SELECT r1.Con, (r1.V - r2.V) as Margin FROM (SELECT c.Name as Con, COUNT(v.VoteID) as V, ROW_NUMBER() OVER(PARTITION BY c.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) as r FROM Candidate can JOIN Vote v ON can.CandidateID=v.CandidateID JOIN Constituency c ON can.ConstituencyID=c.ConstituencyID GROUP BY can.CandidateID, c.ConstituencyID, c.Name) r1 JOIN (SELECT c.Name as Con, COUNT(v.VoteID) as V, ROW_NUMBER() OVER(PARTITION BY c.ConstituencyID ORDER BY COUNT(v.VoteID) DESC) as r FROM Candidate can JOIN Vote v ON can.CandidateID=v.CandidateID JOIN Constituency c ON can.ConstituencyID=c.ConstituencyID GROUP BY can.CandidateID, c.ConstituencyID, c.Name) r2 ON r1.Con = r2.Con WHERE r1.r=1 AND r2.r=2) M ORDER BY Margin DESC LIMIT 10;"}
                ]
            },
            {
                "id": "booth_intel",
                "name": "Booth Level Data",
                "queries": [
                    {"id": 26, "title": "High-Intensity Booths", "sql": "SELECT b.BoothName, COUNT(vp.ParticipationID) as Count FROM Booth b JOIN VoterParticipation vp ON b.BoothID=vp.BoothID GROUP BY b.BoothID, b.BoothName ORDER BY Count DESC LIMIT 10;"},
                    {"id": 27, "title": "Booths with Zero Participation", "sql": "SELECT b.BoothName FROM Booth b WHERE b.BoothID NOT IN (SELECT DISTINCT BoothID FROM VoterParticipation);"}
                ]
            },
            {
                "id": "candidate_wealth_sub",
                "name": "Candidate Assets",
                "queries": [
                    {"id": 28, "title": "Richest Party by Candidate Assets", "sql": "SELECT p.PartyName, SUM(c.TotalAssets) as Wealth FROM PoliticalParty p JOIN Candidate c ON p.PartyID=c.PartyID GROUP BY p.PartyName ORDER BY Wealth DESC;"},
                    {"id": 29, "title": "Avg Assets per Winning Candidate", "sql": "SELECT AVG(c.TotalAssets) FROM Candidate c JOIN (SELECT ConstituencyID, CandidateID FROM (SELECT ConstituencyID, CandidateID, RANK() OVER(PARTITION BY ConstituencyID ORDER BY COUNT(VoteID) DESC) as r FROM Vote GROUP BY ConstituencyID, CandidateID) T WHERE r=1) W ON c.CandidateID=W.CandidateID;"}
                ]
            },
            {
                "id": "independent_sub",
                "name": "Independent Strengths",
                "queries": [
                    {"id": 30, "title": "Independent Candidates with high votes", "sql": "SELECT c.Name, COUNT(v.VoteID) as Votes FROM Candidate c JOIN PoliticalParty p ON c.PartyID=p.PartyID JOIN Vote v ON c.CandidateID=v.CandidateID WHERE p.PartyName='Independent' GROUP BY c.CandidateID, c.Name HAVING Votes > 3;"}
                ]
            }
        ]
    },
    {
        "id": "system_audit",
        "name": "System Audit & Integrity",
        "subs": [
            {
                "id": "security_sub",
                "name": "Fraud Detection",
                "queries": [
                    {"id": 31, "title": "Double Voting Audit", "sql": "SELECT v.Name, v.EPIC_Number, COUNT(*) as Attempts FROM Voter v JOIN VoterParticipation vp ON v.VoterID=vp.VoterID GROUP BY v.VoterID HAVING Attempts > 1;"},
                    {"id": 32, "title": "Votes without matching Participation record", "sql": "SELECT COUNT(*) FROM Vote v WHERE (v.VoterID, v.ElectionID) NOT IN (SELECT VoterID, ElectionID FROM VoterParticipation) AND v.CandidateID IS NOT NULL;"}
                ]
            },
            {
                "id": "booth_mgmt_sub",
                "name": "Booth Management",
                "queries": [
                    {"id": 33, "title": "Booth density per Constituency", "sql": "SELECT c.Name, COUNT(b.BoothID) as BoothCount FROM Constituency c LEFT JOIN Booth b ON c.ConstituencyID=b.ConstituencyID GROUP BY c.Name;"},
                    {"id": 34, "title": "Booths with high voter-to-staff ratio proxy", "sql": "SELECT b.BoothName, (SELECT COUNT(*) FROM Voter v WHERE v.ConstituencyID=b.ConstituencyID) / (SELECT COUNT(*) FROM Booth b2 WHERE b2.ConstituencyID=b.ConstituencyID) as Ratio FROM Booth b;"}
                ]
            },
            {
                "id": "observer_sub",
                "name": "Oversight Coverage",
                "queries": [
                    {"id": 35, "title": "Observer Assignment Breakdown", "sql": "SELECT c.Name, COUNT(o.ObserverID) as Observers FROM Constituency c LEFT JOIN Observer o ON c.ConstituencyID=o.AssignedConstituencyID GROUP BY c.Name;"}
                ]
            },
            {
                "id": "access_audit",
                "name": "User Access Logs",
                "queries": [
                    {"id": 36, "title": "Admin Users missing Voter ID links", "sql": "SELECT Username FROM Users WHERE Role='Admin' AND VoterID IS NULL;"},
                    {"id": 37, "title": "Recent User Registrations", "sql": "SELECT Username, CreatedAt FROM Users ORDER BY CreatedAt DESC LIMIT 10;"}
                ]
            },
            {
                "id": "consistency_audit",
                "name": "Data Sanity",
                "queries": [
                    {"id": 38, "title": "Candidates with Invalid Party IDs", "sql": "SELECT Name FROM Candidate WHERE PartyID NOT IN (SELECT PartyID FROM PoliticalParty);"},
                    {"id": 39, "title": "Orphaned Participation Records", "sql": "SELECT COUNT(*) FROM VoterParticipation WHERE VoterID NOT IN (SELECT VoterID FROM Voter);"}
                ]
            },
            {
                "id": "load_sub",
                "name": "System Load Analysis",
                "queries": [
                    {"id": 40, "title": "Peak Voting Hours Heatmap", "sql": "SELECT HOUR(Timestamp) as Hour, COUNT(*) as Count FROM VoterParticipation GROUP BY Hour ORDER BY Count DESC;"}
                ]
            }
        ]
    },
    {
        "id": "candidate_bio",
        "name": "Candidate Wealth & Profiling",
        "subs": [
            {
                "id": "wealth_rank_sub",
                "name": "Wealth Rankings",
                "queries": [
                    {"id": 41, "title": "Top 10 Crorepatis", "sql": "SELECT Name, TotalAssets FROM Candidate ORDER BY TotalAssets DESC LIMIT 10;"},
                    {"id": 42, "title": "Candidates with Assets < 10 Lakhs", "sql": "SELECT Name, TotalAssets FROM Candidate WHERE TotalAssets < 1000000;"}
                ]
            },
            {
                "id": "party_avg_assets",
                "name": "Party Asset Averages",
                "queries": [
                    {"id": 43, "title": "Avg Candidate Assets by Party", "sql": "SELECT pp.PartyName, AVG(c.TotalAssets) FROM PoliticalParty pp JOIN Candidate c ON pp.PartyID=c.PartyID GROUP BY pp.PartyName;"}
                ]
            },
            {
                "id": "cand_demo_sub",
                "name": "Candidate Demographics",
                "queries": [
                    {"id": 44, "title": "Female Candidate Percentage", "sql": "SELECT (SELECT COUNT(*) FROM Candidate WHERE Gender='Female') * 100 / COUNT(*) FROM Candidate;"},
                    {"id": 45, "title": "Youngest Candidates (< 30 yrs)", "sql": "SELECT Name, TIMESTAMPDIFF(YEAR, DOB, CURDATE()) as Age FROM Candidate WHERE TIMESTAMPDIFF(YEAR, DOB, CURDATE()) < 40;"}
                ]
            },
            {
                "id": "legal_profile",
                "name": "Legal Benchmarks",
                "queries": [
                    {"id": 46, "title": "Candidates with active Complaints", "sql": "SELECT can.Name, COUNT(comp.ComplaintID) FROM Candidate can JOIN Voter v ON can.Name=v.Name JOIN Complaint comp ON v.VoterID=comp.VoterID GROUP BY can.Name;"}
                ]
            },
            {
                "id": "spending_sub",
                "name": "Financial Conduct",
                "queries": [
                    {"id": 47, "title": "Wealthiest Independents", "sql": "SELECT c.Name, c.TotalAssets FROM Candidate c JOIN PoliticalParty p ON c.PartyID=p.PartyID WHERE p.PartyName='Independent' ORDER BY c.TotalAssets DESC;"}
                ]
            }
        ]
    },
    {
        "id": "regional_insights",
        "name": "Regional & State Insights",
        "subs": [
            {
                "id": "state_perf_sub",
                "name": "State Highlights",
                "queries": [
                    {"id": 48, "title": "Voter Turnout % by State & Election", "sql": "SELECT c.State, e.Title as Election, ROUND(COUNT(vp.ParticipationID)*100/(SELECT COUNT(*) FROM Voter v2 JOIN Constituency c2 ON v2.ConstituencyID=c2.ConstituencyID WHERE c2.State=c.State), 2) as TurnoutPct FROM Constituency c JOIN VoterParticipation vp ON c.ConstituencyID=vp.ConstituencyID JOIN Election e ON vp.ElectionID=e.ElectionID GROUP BY c.State, e.ElectionID, e.Title;"},
                ]
            },
            {
                "id": "urban_rural_split",
                "name": "Urban vs Rural Divide",
                "queries": [
                    {"id": 49, "title": "Urban vs Rural Participation (Per Election)", "sql": "SELECT c.Type, e.Title, COUNT(vp.ParticipationID) as Participation FROM Constituency c JOIN VoterParticipation vp ON c.ConstituencyID=vp.ConstituencyID JOIN Election e ON vp.ElectionID=e.ElectionID GROUP BY c.Type, e.ElectionID, e.Title;"},
                ]
            }
        ]
    }
]

# Flatten list for logic
QUERIES = []
for cat in QUERY_HIERARCHY:
    for sub in cat['subs']:
        QUERIES.extend(sub['queries'])
