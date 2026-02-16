USE ElectionSystem;

-- =============================================
-- TRIGGERS
-- =============================================

DELIMITER //

-- 1. Trigger to Block Votes Outside Election Dates
DROP TRIGGER IF EXISTS Before_Vote_Participation_Insert;
CREATE TRIGGER Before_Vote_Participation_Insert
BEFORE INSERT ON VoterParticipation
FOR EACH ROW
BEGIN
    DECLARE v_ElectionDate DATE;
    DECLARE v_Status ENUM('Scheduled', 'Ongoing', 'Completed');
    
    SELECT ElectionDate, Status INTO v_ElectionDate, v_Status
    FROM Election
    WHERE ElectionID = NEW.ElectionID;
    
    -- Check if Election is 'Ongoing' or date matches (Assuming 1-day election for simplicity)
    IF v_Status != 'Ongoing' AND v_ElectionDate != CAST(NOW() AS DATE) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Voting is not allowed outside the election period or for closed elections.';
    END IF;
END //

-- 2. Trigger to Log Complaint Status Change (Audit Trail - Optional)
-- Simulating "Prevent double voting" is handled by UNIQUE constraints, 
-- but we can add a custom nice error message trigger if desired, 
-- though the Primary Key/Unique Key violation occurs before this if checking same table.
-- Instead, let's ensure Voter belongs to the Constituency where they are voting.
DROP TRIGGER IF EXISTS Validate_Voter_Constituency;
CREATE TRIGGER Validate_Voter_Constituency
BEFORE INSERT ON VoterParticipation
FOR EACH ROW
BEGIN
    DECLARE v_VoterConstituency INT;
    
    SELECT ConstituencyID INTO v_VoterConstituency
    FROM Voter
    WHERE VoterID = NEW.VoterID;
    
    IF v_VoterConstituency != NEW.ConstituencyID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Voter can only vote in their registered constituency.';
    END IF;
END //

DELIMITER ;

-- =============================================
-- VIEWS
-- =============================================

-- 1. Election Turnout View (Voter Participation %)
CREATE OR REPLACE VIEW View_Election_Turnout AS
SELECT 
    e.Title AS Election,
    c.Name AS Constituency,
    COUNT(vp.VoterID) AS TotalVotes,
    (SELECT COUNT(*) FROM Voter v WHERE v.ConstituencyID = c.ConstituencyID) AS TotalRegisteredVoters,
    ROUND(
        (COUNT(vp.VoterID) * 100.0) / (SELECT COUNT(*) FROM Voter v WHERE v.ConstituencyID = c.ConstituencyID), 2
    ) AS TurnoutPercentage
FROM Election e
JOIN VoterParticipation vp ON e.ElectionID = vp.ElectionID
JOIN Constituency c ON vp.ConstituencyID = c.ConstituencyID
GROUP BY e.ElectionID, c.ConstituencyID, e.Title, c.Name;

-- 2. Party Performance View (Total Votes across all elections)
CREATE OR REPLACE VIEW View_Party_Performance AS
SELECT 
    pp.PartyName,
    pp.Symbol,
    COUNT(v.VoteID) AS TotalVotesSecured
FROM PoliticalParty pp
JOIN Candidate c ON pp.PartyID = c.PartyID
JOIN Vote v ON c.CandidateID = v.CandidateID
GROUP BY pp.PartyID, pp.PartyName, pp.Symbol
ORDER BY TotalVotesSecured DESC;

-- 3. Candidate Statistics View
CREATE OR REPLACE VIEW View_Candidate_Stats AS
SELECT 
    e.Title AS Election,
    c.Name AS CandidateName,
    pp.PartyName,
    con.Name AS Constituency,
    COUNT(v.VoteID) AS VotesReceived
FROM Candidate c
JOIN PoliticalParty pp ON c.PartyID = pp.PartyID
JOIN Election e ON c.ElectionID = e.ElectionID
JOIN Constituency con ON c.ConstituencyID = con.ConstituencyID
LEFT JOIN Vote v ON c.CandidateID = v.CandidateID
GROUP BY c.CandidateID, e.ElectionID, c.Name, pp.PartyName, con.Name, e.Title
ORDER BY VotesReceived DESC;

-- 4. Demographic Statistics View (Gender-wise Turnout)
CREATE OR REPLACE VIEW View_Demographic_Stats AS
SELECT 
    e.Title AS Election,
    vr.Gender,
    COUNT(vp.VoterID) AS VotesCast
FROM VoterParticipation vp
JOIN Voter vr ON vp.VoterID = vr.VoterID
JOIN Election e ON vp.ElectionID = e.ElectionID
GROUP BY e.ElectionID, vr.Gender, e.Title;

-- =============================================
-- STORED PROCEDURES
-- =============================================

DELIMITER //

-- Declare Election Results for a specific Election
DROP PROCEDURE IF EXISTS DeclareElectionResults;
CREATE PROCEDURE DeclareElectionResults(IN p_ElectionID INT)
BEGIN
    SELECT 
        c.Name AS Constituency,
        cand.Name AS WinnerName,
        pp.PartyName AS WinningParty,
        VoteCount AS Votes
    FROM (
        SELECT 
            CandidateID, 
            COUNT(*) as VoteCount 
        FROM Vote 
        WHERE ElectionID = p_ElectionID 
        GROUP BY CandidateID
    ) AS Tally
    JOIN Candidate cand ON Tally.CandidateID = cand.CandidateID
    JOIN PoliticalParty pp ON cand.PartyID = pp.PartyID
    JOIN Constituency c ON cand.ConstituencyID = c.ConstituencyID
    -- This is a simplified "Max" logic. In reality, we need rank.
    -- Using Window Function for accuracy:
    WHERE (cand.ConstituencyID, Tally.VoteCount) IN (
        SELECT 
            cand2.ConstituencyID, 
            MAX(Tally2.VoteCount) 
        FROM (
             SELECT CandidateID, COUNT(*) as VoteCount 
             FROM Vote WHERE ElectionID = p_ElectionID 
             GROUP BY CandidateID
        ) AS Tally2
        JOIN Candidate cand2 ON Tally2.CandidateID = cand2.CandidateID
        GROUP BY cand2.ConstituencyID
    )
    ORDER BY c.Name;
END //

DELIMITER ;
