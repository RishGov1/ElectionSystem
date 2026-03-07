-- National Election & Voter Analytics System
-- Key Entities: Voter, Constituency, Election, PoliticalParty, Candidate, Booth, Vote, Observer, Complaint

CREATE DATABASE IF NOT EXISTS ElectionSystem;
USE ElectionSystem;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Vote;
DROP TABLE IF EXISTS VoterParticipation;
DROP TABLE IF EXISTS Complaint;
DROP TABLE IF EXISTS Observer;
DROP TABLE IF EXISTS Candidate;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Voter;
DROP TABLE IF EXISTS Booth;
DROP TABLE IF EXISTS Election;
DROP TABLE IF EXISTS Constituency;
DROP TABLE IF EXISTS PoliticalParty;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Political Party Table
CREATE TABLE IF NOT EXISTS PoliticalParty (
    PartyID INT AUTO_INCREMENT PRIMARY KEY,
    PartyName VARCHAR(100) NOT NULL UNIQUE,
    Symbol VARCHAR(100) NOT NULL,
    Leader VARCHAR(100),
    FoundationDate DATE
);

-- 2. Constituency Table
CREATE TABLE IF NOT EXISTS Constituency (
    ConstituencyID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    State VARCHAR(100) NOT NULL,
    Type ENUM('Rural', 'Urban', 'Semi-Urban') NOT NULL
);

-- 3. Election Table
CREATE TABLE IF NOT EXISTS Election (
    ElectionID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    ElectionDate DATE NOT NULL,
    Type ENUM('General', 'State', 'Municipal', 'By-Election') NOT NULL,
    Status ENUM('Scheduled', 'Ongoing', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    Description TEXT
);

-- 4. Booth Table (Polling Station)
CREATE TABLE IF NOT EXISTS Booth (
    BoothID INT AUTO_INCREMENT PRIMARY KEY,
    ConstituencyID INT NOT NULL,
    BoothName VARCHAR(150) NOT NULL,
    Location VARCHAR(200) NOT NULL,
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5. Voter Table
CREATE TABLE IF NOT EXISTS Voter (
    VoterID INT AUTO_INCREMENT PRIMARY KEY,
    EPIC_Number VARCHAR(20) NOT NULL UNIQUE,
    Name VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    Address TEXT NOT NULL,
    ConstituencyID INT NOT NULL,
    RegistrationDate DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 6. Candidate Table
CREATE TABLE IF NOT EXISTS Candidate (
    CandidateID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    PartyID INT NOT NULL,
    ConstituencyID INT NOT NULL,
    ElectionID INT NOT NULL,
    AffidavitDetails TEXT,
    TotalAssets DECIMAL(15, 2),
    Gender ENUM('Male', 'Female', 'Other') NOT NULL DEFAULT 'Male',
    DOB DATE,
    FOREIGN KEY (PartyID) REFERENCES PoliticalParty(PartyID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    UNIQUE (CandidateID, ElectionID) -- Candidate runs once per election (simplified)
);

-- 7. Voter Participation (Tracking who voted to prevent double voting)
CREATE TABLE IF NOT EXISTS VoterParticipation (
    ParticipationID INT AUTO_INCREMENT PRIMARY KEY,
    ElectionID INT NOT NULL,
    VoterID INT NOT NULL,
    ConstituencyID INT NOT NULL,
    BoothID INT,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID),
    FOREIGN KEY (VoterID) REFERENCES Voter(VoterID),
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID),
    FOREIGN KEY (BoothID) REFERENCES Booth(BoothID),
    UNIQUE (ElectionID, VoterID) -- CRITICAL: Prevents double voting
);

-- 8. Vote Table (The Ballot - Anonymous/Weak Entity)
-- In a real system, this would not link back to VoterID directly relative to Participation.
-- For this academic project, we strictly separate it.
CREATE TABLE IF NOT EXISTS Vote (
    VoteID INT AUTO_INCREMENT PRIMARY KEY,
    ElectionID INT NOT NULL,
    ConstituencyID INT NOT NULL,
    CandidateID INT NOT NULL,
    BoothID INT NOT NULL,
    VoteTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID),
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID),
    FOREIGN KEY (CandidateID) REFERENCES Candidate(CandidateID),
    FOREIGN KEY (BoothID) REFERENCES Booth(BoothID)
);

-- 9. Observer Table
CREATE TABLE IF NOT EXISTS Observer (
    ObserverID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Role VARCHAR(50) DEFAULT 'General Observer',
    AssignedConstituencyID INT,
    ElectionID INT,
    FOREIGN KEY (AssignedConstituencyID) REFERENCES Constituency(ConstituencyID),
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID)
);

-- 10. Complaint Table
CREATE TABLE IF NOT EXISTS Complaint (
    ComplaintID INT AUTO_INCREMENT PRIMARY KEY,
    VoterID INT,
    ElectionID INT,
    Description TEXT NOT NULL,
    Status ENUM('Pending', 'In Progress', 'Resolved', 'Dismissed') DEFAULT 'Pending',
    FiledDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (VoterID) REFERENCES Voter(VoterID),
    FOREIGN KEY (ElectionID) REFERENCES Election(ElectionID)
);

-- 11. Users Table (Authentication)
CREATE TABLE IF NOT EXISTS Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role ENUM('Admin', 'Voter') NOT NULL,
    VoterID INT NULL, -- Linked to VoterID for Voter role
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (VoterID) REFERENCES Voter(VoterID)
        ON UPDATE CASCADE ON DELETE SET NULL
);
