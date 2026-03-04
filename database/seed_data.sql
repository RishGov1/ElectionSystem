USE ElectionSystem;

-- 1. Insert Political Parties
INSERT INTO PoliticalParty (PartyName, Symbol, Leader, FoundationDate) VALUES 
('National Progress Party', 'Sun', 'Amit Verma', '1995-08-15'),
('People’s Voice', 'Microphone', 'Sarah Khan', '2010-01-26'),
('Green Earth Alliance', 'Tree', 'Rajesh Gupta', '2005-06-05'),
('United People''s Alliance', 'Rising Sun', 'Rajesh Khanna', '2015-05-12'),
('Justice and Peace Party', 'Balance Scale', 'Sarah Jacob', '2018-11-20'),
('Independent', 'Kite', 'N/A', NULL);

-- 2. Insert Constituencies
INSERT INTO Constituency (Name, State, Type) VALUES 
('North Delhi', 'Delhi', 'Urban'),
('South Bengaluru', 'Karnataka', 'Urban'),
('Varanasi', 'Uttar Pradesh', 'Semi-Urban'),
('Wayanad', 'Kerala', 'Rural'),
('Jaipur City', 'Rajasthan', 'Urban'),
('Lucknow Central', 'Uttar Pradesh', 'Urban'),
('Thiruvananthapuram', 'Kerala', 'Urban'),
('Patna Sahib', 'Bihar', 'Urban');

-- 3. Insert Booths
INSERT INTO Booth (ConstituencyID, BoothName, Location) VALUES 
(1, 'Model School, Rohini', 'Sector 15, Rohini'),
(1, 'Govt Primary School', 'Pitampura'),
(2, 'Community Hall', 'Jayanagar'),
(2, 'Public Library', 'JP Nagar'),
(3, 'Town Hall', 'Sigra'),
(4, 'Village Panchayat Office', 'Kalpetta');

-- 4. Insert Elections
INSERT INTO Election (Title, ElectionDate, Type, Status, Description) VALUES 
('General Election 2019', '2019-05-23', 'General', 'Completed', '17th Lok Sabha Election'),
('State Assembly 2024', CURDATE(), 'State', 'Ongoing', 'State Legislative Assembly Election'),
('Local Body Election 2025', '2025-06-10', 'Municipal', 'Scheduled', 'Municipal Council Elections'),
('State Assembly 2025', '2025-10-01', 'State', 'Scheduled', 'State Legislative Assembly Election');

-- 5. Insert Voters (Sample 10)
INSERT INTO Voter (EPIC_Number, Name, DOB, Gender, Address, ConstituencyID) VALUES 
('DEL001', 'Aarav Sharma', '1990-05-10', 'Male', 'Flat 101, Rohini', 1),
('DEL002', 'Vihaan Singh', '1985-11-20', 'Male', 'Sector 3, Pitampura', 1),
('DEL003', 'Ananya Iyer', '1992-07-15', 'Female', 'Rohini', 1),
('BLR001', 'Ishaan Kumar', '1998-02-28', 'Male', 'Jayanagar 4th Block', 2),
('BLR002', 'Saanvi Reddy', '1980-09-12', 'Female', 'JP Nagar Phase 1', 2),
('UP001', 'Rohan Mishra', '1975-03-30', 'Male', 'Sigra, Varanasi', 3),
('UP002', 'Priya Yadav', '1995-12-05', 'Female', 'Lanka, Varanasi', 3),
('KER001', 'Mohammed Hafiz', '1988-06-18', 'Male', 'Kalpetta Main Rd', 4),
('KER002', 'Lakshmi Nair', '1990-01-15', 'Female', 'Meppadi', 4),
('DEL004', 'Kavita Das', '1999-08-22', 'Female', 'Sector 9, Rohini', 1);

-- 6. Insert Candidates
-- Election 1 (2019)
INSERT INTO Candidate (Name, PartyID, ConstituencyID, ElectionID, AffidavitDetails, TotalAssets) VALUES 
('Amit Verma', 1, 1, 1, 'Clean Record', 50000000),
('Sarah Khan', 2, 1, 1, 'No Criminal Cases', 15000000),
('Independent Candidate 1', 4, 1, 1, 'Self Employed', 200000),
('Rajesh Gupta', 3, 2, 1, 'Environmentalist', 10000000),
('Local Leader 1', 1, 2, 1, 'Social Worker', 25000000);

-- Election 2 (2024 - Ongoing)
INSERT INTO Candidate (Name, PartyID, ConstituencyID, ElectionID, AffidavitDetails, TotalAssets) VALUES 
('Amit Verma', 1, 1, 2, 'Incumbent', 60000000),
('New Challenger', 2, 1, 2, 'Lawyer', 20000000),
('Saanvi Reddy (Protest)', 4, 2, 2, 'Activist', 5000000),
('Vikram Seth', 1, 5, 3, 'PhD', 8000000),
('Meenakshi Lekhi', 2, 5, 3, 'Lawyer', 4500000),
('Sarah Jacob', 6, 6, 3, 'MBA', 3000000),
('Rajesh Khanna', 5, 6, 3, 'Graduate', 5500000);

-- 7. Insert Participation & Votes (History - Election 1)
-- Voter 1, 2, 3 vote in Election 1 (Const 1)
INSERT INTO VoterParticipation (ElectionID, VoterID, ConstituencyID, BoothID, Timestamp) VALUES 
(1, 1, 1, 1, '2019-05-23 08:30:00'),
(1, 2, 1, 1, '2019-05-23 09:15:00'),
(1, 3, 1, 1, '2019-05-23 10:00:00');

INSERT INTO Vote (ElectionID, ConstituencyID, CandidateID, BoothID, VoteTime) VALUES 
(1, 1, 1, 1, '2019-05-23 08:30:05'), -- Vote for Amit
(1, 1, 1, 1, '2019-05-23 09:15:05'), -- Vote for Amit
(1, 1, 2, 1, '2019-05-23 10:00:05'); -- Vote for Sarah

-- Voter 4, 5 vote in Election 1 (Const 2)
INSERT INTO VoterParticipation (ElectionID, VoterID, ConstituencyID, BoothID, Timestamp) VALUES 
(1, 4, 2, 3, '2019-05-23 11:30:00'),
(1, 5, 2, 4, '2019-05-23 12:00:00');

INSERT INTO Vote (ElectionID, ConstituencyID, CandidateID, BoothID, VoteTime) VALUES 
(1, 2, 4, 3, '2019-05-23 11:30:05'), -- Vote for Rajesh
(1, 2, 5, 4, '2019-05-23 12:00:05'); -- Vote for Local Leader

-- 8. Insert Participation & Votes (Ongoing - Election 2)
-- Current Date
INSERT INTO VoterParticipation (ElectionID, VoterID, ConstituencyID, BoothID, Timestamp) VALUES 
(2, 1, 1, 1, NOW()),
(2, 10, 1, 1, NOW());

INSERT INTO Vote (ElectionID, ConstituencyID, CandidateID, BoothID, VoteTime) VALUES 
(2, 1, 6, 1, NOW()), -- Vote for Amit (Incumbent)
(2, 1, 7, 1, NOW()); -- Vote for New Challenger

-- 9. Observers
INSERT INTO Observer (Name, AssignedConstituencyID, ElectionID) VALUES 
('Dr. T.N. Seshan (Retd)', 1, 2),
('Election Official B', 2, 2);

-- 10. Complaints
INSERT INTO Complaint (VoterID, ElectionID, Description, Status, FiledDate) VALUES 
(2, 1, 'Long queue at booth', 'Resolved', '2019-05-23 14:00:00'),
(4, 2, 'EVM malfunction', 'Pending', NOW());
