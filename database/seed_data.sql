USE ElectionSystem;

-- Disable foreign key checks to allow truncation/cleanup
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Vote;
TRUNCATE TABLE VoterParticipation;
TRUNCATE TABLE Complaint;
TRUNCATE TABLE Observer;
TRUNCATE TABLE Candidate;
TRUNCATE TABLE Users;
TRUNCATE TABLE Voter;
TRUNCATE TABLE Booth;
TRUNCATE TABLE Election;
TRUNCATE TABLE Constituency;
TRUNCATE TABLE PoliticalParty;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Insert Political Parties (15 rows)
INSERT INTO PoliticalParty (PartyName, Symbol, Leader, FoundationDate) VALUES 
('National Progress Party', 'Sun', 'Amit Verma', '1995-08-15'),
('People''s Voice', 'Microphone', 'Sarah Khan', '2010-01-26'),
('Green Earth Alliance', 'Tree', 'Rajesh Gupta', '2005-06-05'),
('United People''s Alliance', 'Rising Sun', 'Rajesh Khanna', '2015-05-12'),
('Justice and Peace Party', 'Balance Scale', 'Sarah Jacob', '2018-11-20'),
('Liberty Front', 'Eagle', 'John Doe', '2012-04-10'),
('Socialist Union', 'Hammer and Sickle', 'Vikram Singh', '1980-03-12'),
('Heritage Party', 'Temple', 'Meenakshi Iyer', '2000-12-05'),
('Youth Empowerment Party', 'Rocket', 'Siddharth Rao', '2021-09-09'),
('Farmers Front', 'Tractor', 'Gurnam Singh', '1998-07-22'),
('Coastal Alliance', 'Boat', 'Antony Dsouza', '2008-02-14'),
('Mountain People Party', 'Snow Peak', 'Tenzing Norgay', '2014-05-20'),
('Digital India Party', 'Laptop', 'Techie Kumar', '2023-01-01'),
('Common Man Party', 'Broom', 'Arvind Kejriwal', '2012-11-26'),
('Independent', 'Kite', 'N/A', NULL);

-- 2. Insert Constituencies (15 rows)
INSERT INTO Constituency (Name, State, Type) VALUES 
('North Delhi', 'Delhi', 'Urban'),
('South Bengaluru', 'Karnataka', 'Urban'),
('Varanasi', 'Uttar Pradesh', 'Semi-Urban'),
('Wayanad', 'Kerala', 'Rural'),
('Jaipur City', 'Rajasthan', 'Urban'),
('Lucknow Central', 'Uttar Pradesh', 'Urban'),
('Thiruvananthapuram', 'Kerala', 'Urban'),
('Patna Sahib', 'Bihar', 'Urban'),
('Hyderabad East', 'Telangana', 'Urban'),
('Chennai Central', 'Tamil Nadu', 'Urban'),
('Kolkata North', 'West Bengal', 'Urban'),
('Mumbai South', 'Maharashtra', 'Urban'),
('Pune West', 'Maharashtra', 'Urban'),
('Ahmedabad East', 'Gujarat', 'Urban'),
('Indore City', 'Madhya Pradesh', 'Urban');

-- 3. Insert Booths (15 rows)
INSERT INTO Booth (ConstituencyID, BoothName, Location) VALUES 
(1, 'Model School, Rohini', 'Sector 15, Rohini'),
(1, 'Govt Primary School', 'Pitampura'),
(2, 'Community Hall', 'Jayanagar'),
(2, 'Public Library', 'JP Nagar'),
(3, 'Town Hall', 'Sigra'),
(4, 'Village Panchayat Office', 'Kalpetta'),
(5, 'City Palace Precinct', 'Pink City'),
(6, 'Hazratganj Community School', 'Lucknow'),
(7, 'Museum Hall', 'Palayam'),
(8, 'Gandhi Maidan School', 'Patna'),
(9, 'Osmania Univ Gate', 'Hyderabad'),
(10, 'Anna Salai Library', 'Chennai'),
(11, 'Salt Lake Sector 5', 'Kolkata'),
(12, 'Marine Drive Pavillion', 'Mumbai'),
(13, 'Deccan Gymkhana Hall', 'Pune');

-- 4. Insert Elections (15 rows)
INSERT INTO Election (Title, ElectionDate, Type, Status, Description) VALUES 
('General Election 2014', '2014-05-16', 'General', 'Completed', '16th Lok Sabha'),
('General Election 2019', '2019-05-23', 'General', 'Completed', '17th Lok Sabha'),
('State Assembly Karnataka 2023', '2023-05-10', 'State', 'Completed', 'State Assembly'),
('State Assembly Rajasthan 2023', '2023-11-25', 'State', 'Completed', 'State Assembly'),
('State Assembly 2024', '2024-03-01', 'State', 'Ongoing', 'Active State Election'),
('Local Body Delhi 2022', '2022-12-04', 'Municipal', 'Completed', 'MCD'),
('By-Election Varanasi 2024', '2024-02-15', 'By-Election', 'Completed', 'MP Resignation'),
('Municipal Mumbai 2025', '2025-02-10', 'Municipal', 'Scheduled', 'Upcoming'),
('General Election 2024', '2024-06-04', 'General', 'Completed', '18th Lok Sabha'),
('State Assembly Kerala 2026', '2026-05-01', 'State', 'Scheduled', 'Future'),
('Panchayat Election 2024', '2024-08-12', 'Municipal', 'Completed', 'Village Level'),
('By-Election Wayanad 2024', '2024-09-15', 'By-Election', 'Completed', 'Vacant Seat'),
('State Assembly UP 2027', '2027-03-20', 'State', 'Scheduled', 'Future General'),
('State Assembly Gujarat 2027', '2027-12-10', 'State', 'Scheduled', 'Future'),
('Municipal Bangalore 2024', '2024-11-15', 'Municipal', 'Completed', 'Upcoming');

-- 5. Insert Voters (20 rows)
INSERT INTO Voter (EPIC_Number, Name, DOB, Gender, Address, ConstituencyID) VALUES 
('DEL001', 'Aarav Sharma', '2004-05-10', 'Male', 'Flat 101, Rohini', 1),
('DEL002', 'Vihaan Singh', '2005-11-20', 'Male', 'Sector 3, Pitampura', 1),
('DEL003', 'Ananya Iyer', '2002-07-15', 'Female', 'Rohini', 1),
('BLR001', 'Ishaan Kumar', '2001-02-28', 'Male', 'Jayanagar 4th Block', 2),
('BLR002', 'Saanvi Reddy', '1980-09-12', 'Female', 'JP Nagar Phase 1', 2),
('UP001', 'Rohan Mishra', '1975-03-30', 'Male', 'Sigra, Varanasi', 3),
('UP002', 'Priya Yadav', '1995-12-05', 'Female', 'Lanka, Varanasi', 3),
('KER001', 'Mohammed Hafiz', '1988-06-18', 'Male', 'Kalpetta Main Rd', 4),
('KER002', 'Lakshmi Nair', '1990-01-15', 'Female', 'Meppadi', 4),
('RAJ001', 'Karan Johar', '1982-05-25', 'Male', 'C-Scheme, Jaipur', 5),
('RAJ002', 'Deepika P', '1986-01-05', 'Female', 'Malviya Nagar', 5),
('LKO001', 'Aditya Roy', '2000-11-11', 'Male', 'Hazratganj', 6),
('LKO002', 'Sarah Khan', '2005-04-20', 'Female', 'Gomti Nagar', 6),
('TVM001', 'Rahul Dravid', '1973-01-11', 'Male', 'Civil Lines', 7),
('PAT001', 'Manoj Bajpayee', '1969-04-23', 'Male', 'Boring Road', 8),
('HYD001', 'Allu Arjun', '1983-04-08', 'Male', 'Jubilee Hills', 9),
('CHN001', 'Rajinikanth', '1950-12-12', 'Male', 'Poes Garden', 10),
('KOL001', 'Saurav Ganguly', '1972-07-08', 'Male', 'Behala', 11),
('MUM001', 'Sachin Tendulkar', '1973-04-24', 'Male', 'Bandra', 12),
('PUN001', 'Virat Kohli', '1988-11-05', 'Male', 'Koregaon Park', 13);

-- 6. Insert Users (Auth) (15 rows)
INSERT INTO Users (Username, Password, Role, VoterID) VALUES 
('admin', 'admin123', 'Admin', NULL),
('aarav', 'voter123', 'Voter', 1),
('vihaan', 'voter123', 'Voter', 2),
('ananya', 'voter123', 'Voter', 3),
('ishaan', 'voter123', 'Voter', 4),
('saanvi', 'voter123', 'Voter', 5),
('rohan', 'voter123', 'Voter', 6),
('priya', 'voter123', 'Voter', 7),
('hafiz', 'voter123', 'Voter', 8),
('lakshmi', 'voter123', 'Voter', 9),
('karan', 'voter123', 'Voter', 10),
('deepika', 'voter123', 'Voter', 11),
('aditya', 'voter123', 'Voter', 12),
('sarah', 'voter123', 'Voter', 13),
('rahul', 'voter123', 'Voter', 14);

-- 7. Insert Candidates (20 rows)
INSERT INTO Candidate (Name, PartyID, ConstituencyID, ElectionID, AffidavitDetails, TotalAssets, Gender, DOB) VALUES 
('Amit Verma', 1, 1, 2, 'Clean Record', 50000000, 'Male', '1975-01-15'),
('Sarah Khan', 2, 1, 2, 'No Criminal Cases', 15000000, 'Female', '1985-04-20'),
('Rajesh Gupta', 3, 2, 2, 'Environmentalist', 10000000, 'Male', '1968-11-30'),
('John Doe', 6, 3, 2, 'Educated', 2000000, 'Male', '1982-06-12'),
('Vikram Singh', 7, 4, 2, 'Labor Leader', 500000, 'Male', '1970-03-25'),
('Meenakshi Iyer', 8, 5, 2, 'Lawyer', 12000000, 'Female', '1978-09-05'),
('Siddharth Rao', 9, 6, 2, 'Young blood', 1000000, 'Male', '1995-12-12'),
('Gurnam Singh', 10, 7, 2, 'Farmer rights', 3000000, 'Male', '1965-07-22'),
('Antony Dsouza', 11, 8, 2, 'Fisherman rep', 1500000, 'Male', '1972-02-14'),
('Tenzing Norgay', 12, 9, 2, 'Mountaineer', 800000, 'Male', '1980-05-20'),
('Techie Kumar', 13, 10, 2, 'IT professional', 45000000, 'Male', '1988-01-01'),
('Arvind Kejriwal', 14, 11, 2, 'Social Worker', 2500000, 'Male', '1968-08-16'),
('Candidate 13', 1, 12, 2, 'Business', 100000000, 'Male', '1960-10-10'),
('Candidate 14', 2, 13, 2, 'Doctor', 20000000, 'Female', '1975-03-15'),
('Candidate 15', 3, 14, 2, 'Writer', 1500000, 'Male', '1982-05-20'),
('Amit Verma', 1, 1, 5, 'Incumbent', 60000000, 'Male', '1975-01-15'),
('Sarah Khan', 2, 1, 5, 'Challenger', 18000000, 'Female', '1985-04-20'),
('Rajesh Khanna', 4, 2, 5, 'Veteran', 25000000, 'Male', '1955-12-25'),
('Sarah Jacob', 5, 3, 5, 'New entry', 4000000, 'Female', '1990-11-20'),
('Rajesh Gupta', 3, 4, 5, 'Green activist', 11000000, 'Male', '1968-11-30');

-- 8. Insert Participation (15 rows)
-- We ensure unique (ElectionID, VoterID) combinations to prevent >100% turnout
INSERT INTO VoterParticipation (ElectionID, VoterID, ConstituencyID, BoothID, Timestamp) VALUES 
(2, 1, 1, 1, '2019-05-23 08:30:00'),
(2, 2, 1, 1, '2019-05-23 09:15:00'),
(2, 3, 1, 2, '2019-05-23 10:00:00'),
(2, 4, 2, 3, '2019-05-23 11:00:00'),
(2, 5, 2, 4, '2019-05-23 12:00:00'),
(2, 6, 3, 5, '2019-05-23 13:00:00'),
(2, 7, 3, 5, '2019-05-23 14:00:00'),
(2, 8, 4, 6, '2019-05-23 15:00:00'),
(2, 9, 4, 6, '2019-05-23 16:00:00'),
(2, 10, 5, 7, '2019-05-23 08:30:00'),
(8, 11, 5, 7, NOW()),
(8, 12, 6, 8, NOW()),
(8, 13, 6, 8, NOW()),
(8, 14, 7, 9, NOW()),
(8, 15, 8, 10, NOW());

-- 9. Insert Votes (15 rows)
-- Votes must correspond to Participation for analytical consistency
INSERT INTO Vote (ElectionID, ConstituencyID, CandidateID, BoothID, VoteTime) VALUES 
(2, 1, 1, 1, '2019-05-23 08:30:05'),
(2, 1, 1, 1, '2019-05-23 09:15:05'),
(2, 1, 2, 2, '2019-05-23 10:00:05'),
(2, 2, 3, 3, '2019-05-23 11:00:05'),
(2, 2, 3, 4, '2019-05-23 12:00:05'),
(2, 3, 4, 5, '2019-05-23 13:00:05'),
(2, 3, 4, 5, '2019-05-23 14:00:05'),
(2, 4, 5, 6, '2019-05-23 15:00:05'),
(2, 4, 5, 6, '2019-05-23 16:00:05'),
(2, 5, 6, 7, '2019-05-23 08:30:05'),
(8, 5, 6, 7, NOW()),
(8, 6, 7, 8, NOW()),
(8, 6, 7, 8, NOW()),
(8, 7, 8, 9, NOW()),
(8, 8, 9, 10, NOW());

-- 10. Observers (15 rows)
INSERT INTO Observer (Name, AssignedConstituencyID, ElectionID) VALUES 
('Observer 1', 1, 2), ('Observer 2', 2, 2), ('Observer 3', 3, 2),
('Observer 4', 4, 2), ('Observer 5', 5, 2), ('Observer 6', 6, 2),
('Observer 7', 7, 2), ('Observer 8', 8, 2), ('Observer 9', 9, 2),
('Observer 10', 10, 2), ('Observer 11', 11, 2), ('Observer 12', 12, 2),
('Observer 13', 1, 5), ('Observer 14', 2, 5), ('Observer 15', 3, 5);

-- 11. Complaints (15 rows)
INSERT INTO Complaint (VoterID, ElectionID, Description, Status, FiledDate) VALUES 
(1, 2, 'Booth capture attempt', 'Resolved', '2019-05-23 10:00:00'),
(2, 2, 'Delayed voting', 'Resolved', '2019-05-23 11:00:00'),
(4, 2, 'EVM malfunction', 'Dismissed', '2019-05-23 12:00:00'),
(5, 2, 'Crowd control issues', 'Resolved', '2019-05-23 13:00:00'),
(6, 2, 'Missing name in list', 'In Progress', '2019-05-23 14:00:00'),
(7, 2, 'Fake voter detected', 'Resolved', '2019-05-23 15:00:00'),
(8, 2, 'Officer bias', 'Pending', '2019-05-23 16:00:00'),
(9, 2, 'Inaccessible booth', 'Resolved', '2019-05-23 17:00:00'),
(10, 2, 'Light failure', 'Resolved', '2019-05-23 18:00:00'),
(11, 5, 'No ink available', 'Pending', NOW()),
(12, 5, 'Booth too far', 'In Progress', NOW()),
(13, 5, 'Queue jumping', 'Resolved', NOW()),
(14, 5, 'EVM sound issue', 'Pending', NOW()),
(15, 5, 'Voter intimidation', 'Resolved', NOW()),
(1, 5, 'Test complaint', 'Resolved', NOW());
