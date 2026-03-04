DROP DATABASE IF EXISTS election_system;
CREATE DATABASE election_system;
USE election_system;

-- 1. Constituency Table
CREATE TABLE Constituency (
    constituency_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    total_voters INT DEFAULT 0,
    area_sqkm DECIMAL(10,2),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_constituency_name (name, state)
) ENGINE=InnoDB;

-- 2. Voter Table
CREATE TABLE Voter (
    voter_id INT PRIMARY KEY AUTO_INCREMENT,
    national_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    constituency_id INT NOT NULL,
    registration_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Active', 'Inactive', 'Deceased', 'Migrated') DEFAULT 'Active',
    FOREIGN KEY (constituency_id) REFERENCES Constituency(constituency_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (date_of_birth <= DATE_SUB(CURDATE(), INTERVAL 18 YEAR)),
    INDEX idx_voter_constituency (constituency_id),
    INDEX idx_voter_status (status)
) ENGINE=InnoDB;

-- 3. Political Party Table
CREATE TABLE PoliticalParty (
    party_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    symbol VARCHAR(50),
    founded_year YEAR,
    headquarters VARCHAR(100),
    leader_name VARCHAR(100),
    registration_number VARCHAR(50) UNIQUE NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. Election Table
CREATE TABLE Election (
    election_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type ENUM('General', 'State', 'Local', 'By-Election') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_eligible_voters INT DEFAULT 0,
    total_votes_cast INT DEFAULT 0,
    status ENUM('Scheduled', 'Ongoing', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_date >= start_date),
    CHECK (start_date >= CURRENT_DATE OR status != 'Scheduled'),
    INDEX idx_election_dates (start_date, end_date),
    INDEX idx_election_status (status)
) ENGINE=InnoDB;

-- 5. Booth Table
CREATE TABLE Booth (
    booth_id INT PRIMARY KEY AUTO_INCREMENT,
    booth_number VARCHAR(20) NOT NULL,
    building VARCHAR(100),
    area VARCHAR(100),
    pincode VARCHAR(10),
    capacity INT DEFAULT 1000,
    constituency_id INT NOT NULL,
    status ENUM('Active', 'Inactive', 'Under Maintenance') DEFAULT 'Active',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (constituency_id) REFERENCES Constituency(constituency_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY uk_booth_number (booth_number, constituency_id),
    INDEX idx_booth_constituency (constituency_id)
) ENGINE=InnoDB;

-- 6. Candidate Table
CREATE TABLE Candidate (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    party_id INT NOT NULL,
    education VARCHAR(100),
    criminal_records TEXT,
    assets DECIMAL(15,2) DEFAULT 0.00,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (party_id) REFERENCES PoliticalParty(party_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (date_of_birth <= DATE_SUB(CURDATE(), INTERVAL 25 YEAR)),
    INDEX idx_candidate_party (party_id)
) ENGINE=InnoDB;

-- 7. Candidate Registration Table (M:N between Candidate and Election)
CREATE TABLE CandidateRegistration (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    candidate_id INT NOT NULL,
    election_id INT NOT NULL,
    constituency_id INT NOT NULL,
    symbol VARCHAR(50),
    registration_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Registered', 'Approved', 'Rejected', 'Withdrawn') DEFAULT 'Registered',
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (election_id) REFERENCES Election(election_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (constituency_id) REFERENCES Constituency(constituency_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY uk_candidate_election (candidate_id, election_id),
    INDEX idx_reg_election (election_id),
    INDEX idx_reg_constituency (constituency_id)
) ENGINE=InnoDB;

-- 8. Vote Table (WEAK ENTITY - depends on Voter and Election)
CREATE TABLE Vote (
    vote_id INT AUTO_INCREMENT,
    voter_id INT NOT NULL,
    election_id INT NOT NULL,
    candidate_id INT NOT NULL,
    booth_id INT NOT NULL,
    vote_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_hash VARCHAR(64),
    PRIMARY KEY (voter_id, election_id, vote_id),
    FOREIGN KEY (voter_id) REFERENCES Voter(voter_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (election_id) REFERENCES Election(election_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (booth_id) REFERENCES Booth(booth_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_vote_election (election_id),
    INDEX idx_vote_candidate (candidate_id),
    INDEX idx_vote_booth (booth_id),
    INDEX idx_vote_timestamp (vote_timestamp)
) ENGINE=InnoDB;

-- 9. Election Result Table
CREATE TABLE ElectionResult (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    election_id INT NOT NULL,
    constituency_id INT NOT NULL,
    candidate_id INT NOT NULL,
    total_votes INT DEFAULT 0,
    vote_percentage DECIMAL(5,2) DEFAULT 0.00,
    rank_position INT,
    result_status ENUM('Winner', 'Runner-up', 'Defeated') DEFAULT 'Defeated',
    declared_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (election_id) REFERENCES Election(election_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (constituency_id) REFERENCES Constituency(constituency_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY uk_result (election_id, constituency_id, candidate_id),
    INDEX idx_result_election (election_id),
    INDEX idx_result_constituency (constituency_id)
) ENGINE=InnoDB;

-- 10. Observer Table
CREATE TABLE Observer (
    observer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    designation VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    assigned_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 11. Booth Assignment Table (M:N between Observer and Booth)
CREATE TABLE BoothAssignment (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    observer_id INT NOT NULL,
    booth_id INT NOT NULL,
    election_id INT NOT NULL,
    assignment_date DATE DEFAULT (CURRENT_DATE),
    duty_hours VARCHAR(20),
    FOREIGN KEY (observer_id) REFERENCES Observer(observer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (booth_id) REFERENCES Booth(booth_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (election_id) REFERENCES Election(election_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY uk_assignment (observer_id, booth_id, election_id),
    INDEX idx_assignment_booth (booth_id),
    INDEX idx_assignment_election (election_id)
) ENGINE=InnoDB;

-- 12. Complaint Table
CREATE TABLE Complaint (
    complaint_id INT PRIMARY KEY AUTO_INCREMENT,
    voter_id INT,
    election_id INT NOT NULL,
    booth_id INT,
    complaint_type ENUM('Voting Irregularity', 'Booth Misconduct', 'Violence', 'Technical Issue', 'Other') NOT NULL,
    description TEXT NOT NULL,
    filed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Filed', 'Under Review', 'Resolved', 'Dismissed') DEFAULT 'Filed',
    resolution TEXT,
    resolved_date TIMESTAMP NULL,
    FOREIGN KEY (voter_id) REFERENCES Voter(voter_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (election_id) REFERENCES Election(election_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (booth_id) REFERENCES Booth(booth_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_complaint_election (election_id),
    INDEX idx_complaint_status (status)
) ENGINE=InnoDB;


-- Insert Constituencies
INSERT INTO Constituency (name, state, total_voters, area_sqkm) VALUES
('Mumbai North', 'Maharashtra', 150000, 45.5),
('Delhi Chandni Chowk', 'Delhi', 175000, 38.2),
('Bangalore South', 'Karnataka', 200000, 52.8),
('Kolkata North', 'West Bengal', 165000, 41.3),
('Chennai Central', 'Tamil Nadu', 180000, 47.6),
('Hyderabad', 'Telangana', 190000, 50.1),
('Pune City', 'Maharashtra', 155000, 43.7),
('Ahmedabad East', 'Gujarat', 170000, 46.2),
('Jaipur City', 'Rajasthan', 210000, 55.4),
('Lucknow Central', 'Uttar Pradesh', 240000, 48.9),
('Thiruvananthapuram', 'Kerala', 195000, 35.6),
('Patna Sahib', 'Bihar', 225000, 42.1);

-- Insert Political Parties
INSERT INTO PoliticalParty (name, symbol, founded_year, headquarters, leader_name, registration_number) VALUES
('National Democratic Party', 'Lotus', 1980, 'New Delhi', 'Amit Shah', 'REG001'),
('Indian National Alliance', 'Hand', 1885, 'New Delhi', 'Mallikarjun Kharge', 'REG002'),
('Progressive Socialist Party', 'Bicycle', 1992, 'Lucknow', 'Akhilesh Yadav', 'REG003'),
('Regional Development Front', 'Two Leaves', 1972, 'Chennai', 'M.K. Stalin', 'REG004'),
('Citizen Welfare Party', 'Broom', 2012, 'New Delhi', 'Arvind Kejriwal', 'REG005'),
('United People''s Alliance', 'Rising Sun', 2015, 'Mumbai', 'Rajesh Khanna', 'REG006'),
('Justice and Peace Party', 'Balance Scale', 2018, 'Bangalore', 'Sarah Jacob', 'REG007'),
('Independent Candidates', 'Various', NULL, NULL, NULL, 'REG999');

-- Insert Elections
INSERT INTO Election (name, type, start_date, end_date, total_eligible_voters, status) VALUES
('General Election 2024', 'General', '2024-04-15', '2024-05-30', 900000000, 'Completed'),
('State Assembly 2024', 'State', '2024-11-10', '2024-11-25', 50000000, 'Completed'),
('General Election 2025', 'General', '2025-04-01', '2025-05-15', 950000000, 'Scheduled'),
('Local Body Election 2025', 'Local', '2025-06-10', '2025-06-15', 5000000, 'Scheduled'),
('State Assembly 2025', 'State', '2025-10-01', '2025-10-15', 60000000, 'Scheduled');

-- Insert Voters
INSERT INTO Voter (national_id, first_name, last_name, date_of_birth, gender, phone, email, street, city, state, pincode, constituency_id, status) VALUES
('AADH001234567890', 'Rajesh', 'Kumar', '1985-03-15', 'Male', '9876543210', 'rajesh.kumar@email.com', '123 MG Road', 'Mumbai', 'Maharashtra', '400001', 1, 'Active'),
('AADH001234567891', 'Priya', 'Sharma', '1990-07-22', 'Female', '9876543211', 'priya.sharma@email.com', '456 CP Area', 'Delhi', 'Delhi', '110001', 2, 'Active'),
('AADH001234567892', 'Amit', 'Patel', '1988-11-10', 'Male', '9876543212', 'amit.patel@email.com', '789 Brigade Road', 'Bangalore', 'Karnataka', '560001', 3, 'Active'),
('AADH001234567893', 'Sneha', 'Banerjee', '1992-05-18', 'Female', '9876543213', 'sneha.b@email.com', '321 Park Street', 'Kolkata', 'West Bengal', '700001', 4, 'Active'),
('AADH001234567894', 'Vikram', 'Reddy', '1987-09-25', 'Male', '9876543214', 'vikram.r@email.com', '654 Anna Salai', 'Chennai', 'Tamil Nadu', '600001', 5, 'Active'),
('AADH001234567895', 'Anita', 'Desai', '1995-01-30', 'Female', '9876543215', 'anita.d@email.com', '987 FC Road', 'Pune', 'Maharashtra', '411001', 7, 'Active'),
('AADH001234567896', 'Sanjay', 'Gupta', '1983-12-08', 'Male', '9876543216', 'sanjay.g@email.com', '147 CG Road', 'Ahmedabad', 'Gujarat', '380001', 8, 'Active'),
('AADH001234567897', 'Meera', 'Singh', '1991-06-14', 'Female', '9876543217', 'meera.s@email.com', '258 Karol Bagh', 'Delhi', 'Delhi', '110005', 2, 'Active'),
('AADH001234567898', 'Arjun', 'Nair', '1986-08-20', 'Male', '9876543218', 'arjun.n@email.com', '369 Banjara Hills', 'Hyderabad', 'Telangana', '500001', 6, 'Active'),
('AADH001234567899', 'Kavita', 'Joshi', '1994-04-05', 'Female', '9876543219', 'kavita.j@email.com', '741 Whitefield', 'Bangalore', 'Karnataka', '560066', 3, 'Active');

-- Insert Booths
INSERT INTO Booth (booth_number, building, area, pincode, capacity, constituency_id) VALUES
('MN001', 'St. Xavier School', 'Bandra West', '400050', 1200, 1),
('MN002', 'Municipal Hall', 'Andheri', '400053', 1000, 1),
('DC001', 'Government School', 'Chandni Chowk', '110006', 1500, 2),
('DC002', 'Community Center', 'Paharganj', '110055', 1100, 2),
('BS001', 'Tech College', 'Jayanagar', '560041', 1300, 3),
('BS002', 'Public Library', 'BTM Layout', '560076', 1000, 3),
('KN001', 'City Hall', 'Salt Lake', '700064', 1400, 4),
('CC001', 'Corporation School', 'T Nagar', '600017', 1200, 5),
('HY001', 'Jubilee Hall', 'Secunderabad', '500003', 1100, 6),
('PC001', 'College Auditorium', 'Shivaji Nagar', '411005', 1000, 7);

-- Insert Candidates
INSERT INTO Candidate (first_name, last_name, date_of_birth, party_id, education, criminal_records, assets) VALUES
('Mohan', 'Bhargava', '1970-05-12', 1, 'MBA, Law', 'None', 5000000.00),
('Sunita', 'Verma', '1968-08-25', 2, 'PhD Economics', 'None', 3500000.00),
('Rakesh', 'Malhotra', '1975-11-30', 1, 'Engineering', 'None', 4200000.00),
('Deepa', 'Krishnan', '1972-03-18', 4, 'Masters in Public Admin', 'None', 2800000.00),
('Harish', 'Rao', '1969-07-22', 3, 'BSc Agriculture', '1 Minor Case', 6500000.00),
('Nisha', 'Kapoor', '1978-09-14', 5, 'Law Graduate', 'None', 1500000.00),
('Suresh', 'Agarwal', '1971-12-05', 1, 'Commerce Graduate', 'None', 7200000.00),
('Lakshmi', 'Iyer', '1973-06-28', 4, 'Masters in Social Work', 'None', 2100000.00),
('Vikram', 'Seth', '1972-01-05', 1, 'PhD', 'None', 8000000.00),
('Meenakshi', 'Lekhi', '1967-12-30', 2, 'Law', 'None', 4500000.00),
('Rahul', 'Bose', '1980-05-20', 8, 'Bachelors', 'None', 1200000.00),
('Sarah', 'Jacob', '1978-03-12', 7, 'MBA', 'None', 3000000.00),
('Rajesh', 'Khanna', '1965-09-10', 6, 'Graduate', 'None', 5500000.00);

-- Insert Candidate Registrations
INSERT INTO CandidateRegistration (candidate_id, election_id, constituency_id, symbol, status) VALUES
(1, 1, 1, 'Lotus', 'Approved'),
(2, 1, 1, 'Hand', 'Approved'),
(3, 1, 2, 'Lotus', 'Approved'),
(6, 1, 2, 'Broom', 'Approved'),
(4, 1, 5, 'Two Leaves', 'Approved'),
(8, 1, 5, 'Two Leaves', 'Approved'),
(5, 1, 3, 'Bicycle', 'Approved'),
(7, 1, 7, 'Lotus', 'Approved'),
(1, 2, 1, 'Lotus', 'Approved'),
(2, 2, 1, 'Hand', 'Approved'),
(9, 3, 9, 'Lotus', 'Approved'),
(10, 3, 9, 'Hand', 'Approved'),
(12, 3, 10, 'Balance Scale', 'Approved'),
(13, 3, 10, 'Rising Sun', 'Approved'),
(11, 4, 1, 'Various', 'Approved');

-- Insert Votes
INSERT INTO Vote (voter_id, election_id, candidate_id, booth_id, verification_hash) VALUES
(1, 1, 1, 1, SHA2(CONCAT('1', '1', NOW()), 256)),
(2, 1, 3, 3, SHA2(CONCAT('2', '1', NOW()), 256)),
(3, 1, 5, 5, SHA2(CONCAT('3', '1', NOW()), 256)),
(4, 1, 4, 7, SHA2(CONCAT('4', '1', NOW()), 256)),
(5, 1, 4, 8, SHA2(CONCAT('5', '1', NOW()), 256)),
(6, 1, 7, 10, SHA2(CONCAT('6', '1', NOW()), 256)),
(7, 1, 3, 4, SHA2(CONCAT('7', '1', NOW()), 256)),
(8, 1, 4, 9, SHA2(CONCAT('8', '1', NOW()), 256)),
(9, 1, 5, 6, SHA2(CONCAT('9', '1', NOW()), 256)),
(10, 1, 5, 5, SHA2(CONCAT('10', '1', NOW()), 256));

-- Insert Observers
INSERT INTO Observer (first_name, last_name, designation, phone, email) VALUES
('Ramesh', 'Chandra', 'Chief Observer', '9988776655', 'ramesh.c@election.gov'),
('Savita', 'Menon', 'Senior Observer', '9988776656', 'savita.m@election.gov'),
('Prakash', 'Jain', 'Observer', '9988776657', 'prakash.j@election.gov'),
('Geeta', 'Rao', 'Observer', '9988776658', 'geeta.r@election.gov');

-- Insert Booth Assignments
INSERT INTO BoothAssignment (observer_id, booth_id, election_id, duty_hours) VALUES
(1, 1, 1, '7 AM - 7 PM'),
(2, 3, 1, '7 AM - 7 PM'),
(3, 5, 1, '7 AM - 7 PM'),
(4, 7, 1, '7 AM - 7 PM'),
(1, 2, 1, '7 AM - 7 PM'),
(2, 4, 1, '7 AM - 7 PM');

-- Insert Complaints
INSERT INTO Complaint (voter_id, election_id, booth_id, complaint_type, description, status) VALUES
(2, 1, 3, 'Technical Issue', 'EVM machine malfunctioned at 11 AM', 'Resolved'),
(5, 1, 8, 'Voting Irregularity', 'Long queue management issue', 'Under Review'),
(8, 1, 9, 'Booth Misconduct', 'Unauthorized person near voting booth', 'Filed');



-- View 1: Election Turnout Summary
CREATE OR REPLACE VIEW vw_election_turnout AS
SELECT 
    e.election_id,
    e.name AS election_name,
    e.type AS election_type,
    e.start_date,
    e.end_date,
    e.total_eligible_voters,
    COUNT(DISTINCT v.voter_id) AS total_votes_cast,
    ROUND((COUNT(DISTINCT v.voter_id) * 100.0 / NULLIF(e.total_eligible_voters, 0)), 2) AS turnout_percentage,
    e.status
FROM Election e
LEFT JOIN Vote v ON e.election_id = v.election_id
GROUP BY e.election_id, e.name, e.type, e.start_date, e.end_date, 
         e.total_eligible_voters, e.status;

-- View 2: Party-wise Performance
CREATE OR REPLACE VIEW vw_party_performance AS
SELECT 
    e.election_id,
    e.name AS election_name,
    pp.party_id,
    pp.name AS party_name,
    pp.symbol,
    COUNT(DISTINCT cr.candidate_id) AS total_candidates,
    COUNT(DISTINCT v.vote_id) AS total_votes_received,
    ROUND(AVG(er.vote_percentage), 2) AS avg_vote_percentage
FROM Election e
CROSS JOIN PoliticalParty pp
LEFT JOIN Candidate c ON pp.party_id = c.party_id
LEFT JOIN CandidateRegistration cr ON c.candidate_id = cr.candidate_id 
    AND e.election_id = cr.election_id
LEFT JOIN Vote v ON cr.candidate_id = v.candidate_id 
    AND e.election_id = v.election_id
LEFT JOIN ElectionResult er ON cr.candidate_id = er.candidate_id 
    AND e.election_id = er.election_id
GROUP BY e.election_id, e.name, pp.party_id, pp.name, pp.symbol
HAVING total_candidates > 0
ORDER BY e.election_id, total_votes_received DESC;

-- View 3: Candidate-wise Vote Count
CREATE OR REPLACE VIEW vw_candidate_votes AS
SELECT 
    v.election_id,
    e.name AS election_name,
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    pp.name AS party_name,
    con.name AS constituency_name,
    COUNT(v.vote_id) AS total_votes,
    b.booth_number,
    b.building AS booth_location
FROM Vote v
JOIN Candidate c ON v.candidate_id = c.candidate_id
JOIN Election e ON v.election_id = e.election_id
JOIN PoliticalParty pp ON c.party_id = pp.party_id
JOIN Booth b ON v.booth_id = b.booth_id
JOIN Constituency con ON b.constituency_id = con.constituency_id
GROUP BY v.election_id, e.name, c.candidate_id, c.first_name, c.last_name, 
         pp.name, con.name, b.booth_number, b.building
ORDER BY v.election_id, total_votes DESC;


-- Trigger 1: Prevent Double Voting
DELIMITER //
CREATE TRIGGER trg_prevent_double_voting
BEFORE INSERT ON Vote
FOR EACH ROW
BEGIN
    DECLARE vote_count INT;
    
    -- Check if voter has already voted in this election
    SELECT COUNT(*) INTO vote_count
    FROM Vote
    WHERE voter_id = NEW.voter_id 
    AND election_id = NEW.election_id;
    
    IF vote_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Voter has already cast vote in this election';
    END IF;
END;//
DELIMITER ;

-- Trigger 2: Validate Vote Within Election Period
DELIMITER //
CREATE TRIGGER trg_validate_vote_date
BEFORE INSERT ON Vote
FOR EACH ROW
BEGIN
    DECLARE election_start DATE;
    DECLARE election_end DATE;
    DECLARE election_stat VARCHAR(20);
    
    -- Get election dates and status
    SELECT start_date, end_date, status INTO election_start, election_end, election_stat
    FROM Election
    WHERE election_id = NEW.election_id;
    
    -- Check if vote is within election period
    IF CURRENT_DATE < election_start OR CURRENT_DATE > election_end THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vote cannot be cast outside election period';
    END IF;
    
    -- Check if election is ongoing
    IF election_stat != 'Ongoing' AND election_stat != 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Election is not currently active for voting';
    END IF;
END;//
DELIMITER ;

-- Trigger 3: Update Total Votes Cast in Election
DELIMITER //
CREATE TRIGGER trg_update_election_votes
AFTER INSERT ON Vote
FOR EACH ROW
BEGIN
    UPDATE Election
    SET total_votes_cast = (
        SELECT COUNT(DISTINCT voter_id)
        FROM Vote
        WHERE election_id = NEW.election_id
    )
    WHERE election_id = NEW.election_id;
END;//
DELIMITER ;

-- Trigger 4: Update Constituency Total Voters
DELIMITER //
CREATE TRIGGER trg_update_constituency_voters
AFTER INSERT ON Voter
FOR EACH ROW
BEGIN
    UPDATE Constituency
    SET total_voters = (
        SELECT COUNT(*)
        FROM Voter
        WHERE constituency_id = NEW.constituency_id
        AND status = 'Active'
    )
    WHERE constituency_id = NEW.constituency_id;
END;//
DELIMITER ;



-- Procedure 1: Declare Election Results
DELIMITER //
CREATE PROCEDURE sp_declare_election_results(
    IN p_election_id INT,
    IN p_constituency_id INT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_candidate_id INT;
    DECLARE v_total_votes INT;
    DECLARE v_total_constituency_votes INT;
    DECLARE v_vote_percentage DECIMAL(5,2);
    DECLARE v_rank INT DEFAULT 0;
    
    DECLARE candidate_cursor CURSOR FOR
        SELECT 
            c.candidate_id,
            COUNT(v.vote_id) AS total_votes
        FROM CandidateRegistration cr
        JOIN Candidate c ON cr.candidate_id = c.candidate_id
        LEFT JOIN Vote v ON c.candidate_id = v.candidate_id 
            AND v.election_id = p_election_id
        WHERE cr.election_id = p_election_id
        AND cr.constituency_id = p_constituency_id
        AND cr.status = 'Approved'
        GROUP BY c.candidate_id
        ORDER BY total_votes DESC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- Get total votes in constituency
    SELECT COUNT(*) INTO v_total_constituency_votes
    FROM Vote v
    JOIN Booth b ON v.booth_id = b.booth_id
    WHERE v.election_id = p_election_id
    AND b.constituency_id = p_constituency_id;
    
    -- Delete existing results for this election-constituency
    DELETE FROM ElectionResult
    WHERE election_id = p_election_id
    AND constituency_id = p_constituency_id;
    
    -- Open cursor and process results
    OPEN candidate_cursor;
    
    read_loop: LOOP
        FETCH candidate_cursor INTO v_candidate_id, v_total_votes;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET v_rank = v_rank + 1;
        
        -- Calculate vote percentage
        SET v_vote_percentage = CASE 
            WHEN v_total_constituency_votes > 0 
            THEN (v_total_votes * 100.0 / v_total_constituency_votes)
            ELSE 0 
        END;
        
        -- Insert result
        INSERT INTO ElectionResult (
            election_id, constituency_id, candidate_id, 
            total_votes, vote_percentage, rank_position, result_status
        ) VALUES (
            p_election_id, 
            p_constituency_id, 
            v_candidate_id,
            v_total_votes,
            v_vote_percentage,
            v_rank,
            CASE 
                WHEN v_rank = 1 THEN 'Winner'
                WHEN v_rank = 2 THEN 'Runner-up'
                ELSE 'Defeated'
            END
        );
    END LOOP;
    
    CLOSE candidate_cursor;
    
    SELECT 'Results declared successfully' AS message;
END;//
DELIMITER ;

-- Procedure 2: Register New Voter
DELIMITER //
CREATE PROCEDURE sp_register_voter(
    IN p_national_id VARCHAR(20),
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_dob DATE,
    IN p_gender ENUM('Male', 'Female', 'Other'),
    IN p_phone VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_street VARCHAR(100),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(50),
    IN p_pincode VARCHAR(10),
    IN p_constituency_id INT
)
BEGIN
    DECLARE v_age INT;
    DECLARE v_voter_id INT;
    
    -- Calculate age
    SET v_age = TIMESTAMPDIFF(YEAR, p_dob, CURDATE());
    
    -- Check if voter is 18 or older
    IF v_age < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Voter must be at least 18 years old';
    END IF;
    
    -- Insert voter
    INSERT INTO Voter (
        national_id, first_name, last_name, date_of_birth, gender,
        phone, email, street, city, state, pincode, constituency_id
    ) VALUES (
        p_national_id, p_first_name, p_last_name, p_dob, p_gender,
        p_phone, p_email, p_street, p_city, p_state, p_pincode, p_constituency_id
    );
    
    SET v_voter_id = LAST_INSERT_ID();
    
    SELECT v_voter_id AS voter_id, 'Voter registered successfully' AS message;
END;//
DELIMITER ;

-- Procedure 3: Cast Vote
DELIMITER //
CREATE PROCEDURE sp_cast_vote(
    IN p_voter_id INT,
    IN p_election_id INT,
    IN p_candidate_id INT,
    IN p_booth_id INT
)
BEGIN
    DECLARE v_voter_constituency INT;
    DECLARE v_booth_constituency INT;
    DECLARE v_candidate_constituency INT;
    DECLARE v_voter_status VARCHAR(20);
    
    -- Get voter details
    SELECT constituency_id, status INTO v_voter_constituency, v_voter_status
    FROM Voter WHERE voter_id = p_voter_id;
    
    -- Check voter status
    IF v_voter_status != 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Voter is not active';
    END IF;
    
    -- Get booth constituency
    SELECT constituency_id INTO v_booth_constituency
    FROM Booth WHERE booth_id = p_booth_id;
    
    -- Get candidate constituency for this election
    SELECT constituency_id INTO v_candidate_constituency
    FROM CandidateRegistration
    WHERE candidate_id = p_candidate_id AND election_id = p_election_id;
    
    -- Validate constituency matching
    IF v_voter_constituency != v_booth_constituency THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Voter must vote at booth in their constituency';
    END IF;
    
    IF v_voter_constituency != v_candidate_constituency THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Candidate not registered in voter constituency';
    END IF;
    
    -- Insert vote (triggers will handle validation)
    INSERT INTO Vote (voter_id, election_id, candidate_id, booth_id, verification_hash)
    VALUES (
        p_voter_id, 
        p_election_id, 
        p_candidate_id, 
        p_booth_id,
        SHA2(CONCAT(p_voter_id, p_election_id, NOW()), 256)
    );
    
    SELECT 'Vote cast successfully' AS message;
END;//
DELIMITER ;



-- Already created inline with tables, but additional composite indexes:
CREATE INDEX idx_vote_election_candidate ON Vote(election_id, candidate_id);
CREATE INDEX idx_vote_election_booth ON Vote(election_id, booth_id);
CREATE INDEX idx_voter_constituency_status ON Voter(constituency_id, status);
CREATE INDEX idx_candidate_party ON Candidate(party_id);
CREATE INDEX idx_result_election_constituency ON ElectionResult(election_id, constituency_id);

