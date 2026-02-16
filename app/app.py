import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.abspath(os.path.join(current_dir, '..'))

if current_dir in sys.path:
    sys.path.remove(current_dir)
sys.path.append(parent_dir)

from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from app.db import execute_query, execute_procedure, close_db
from app.queries_data import QUERIES

app = Flask(__name__, template_folder='../templates', static_folder='../static')
app.secret_key = 'supersecretkey' 
@app.teardown_appcontext
def teardown_db(error):
    close_db(error)


@app.route('/')
def index():
    # Fetch active elections
    active_elections = execute_query("SELECT * FROM Election WHERE Status = 'Ongoing'")
    return render_template('index.html', elections=active_elections)

# ============================
# VOTER REGISTRATION
# ============================
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        epic = request.form['epic']
        dob = request.form['dob']
        gender = request.form['gender']
        address = request.form['address']
        constituency_id = request.form['constituency']
        
       
        existing = execute_query("SELECT * FROM Voter WHERE EPIC_Number = %s", (epic,), fetch_one=True)
        if existing:
            flash(f"Error: Voter with EPIC {epic} already exists!", "danger")
            return redirect(url_for('register'))

        sql = """INSERT INTO Voter (EPIC_Number, Name, DOB, Gender, Address, ConstituencyID) 
                 VALUES (%s, %s, %s, %s, %s, %s)"""
        execute_query(sql, (epic, name, dob, gender, address, constituency_id), commit=True)
        
        flash("Registration Successful! Please vote.", "success")
        return redirect(url_for('index'))
    
    # GET: Show Form
    constituencies = execute_query("SELECT * FROM Constituency")
    return render_template('register.html', constituencies=constituencies)

# ============================
# VOTING PROCESS
# ============================
@app.route('/vote', methods=['GET', 'POST'])
def vote():
    if request.method == 'POST':
        # Step 1: Validate Voter
        epic = request.form.get('epic')
        election_id = request.form.get('election_id')
        
        if not epic or not election_id:
             if 'candidate_id' in request.form:
                 # CAST VOTE
                 return cast_vote_submit(request)
        
        # Step 2: Login Check
        voter = execute_query("SELECT * FROM Voter WHERE EPIC_Number = %s", (epic,), fetch_one=True)
        if not voter:
            flash("Invalid EPIC Number. Please register first.", "danger")
            return redirect(url_for('vote'))
            
        # Check if already voted
        has_voted = execute_query("SELECT * FROM VoterParticipation WHERE VoterID = %s AND ElectionID = %s", 
                                  (voter['VoterID'], election_id), fetch_one=True)
        if has_voted:
            flash("You have already voted in this election!", "danger")
            return redirect(url_for('index'))
            
        # Fetch Candidates for Voter's Constituency
        constituency_id = voter['ConstituencyID']
        constituency = execute_query("SELECT * FROM Constituency WHERE ConstituencyID = %s", (constituency_id,), fetch_one=True)
        
        candidates = execute_query("""
            SELECT c.CandidateID, c.Name, p.PartyName, p.Symbol 
            FROM Candidate c 
            JOIN PoliticalParty p ON c.PartyID = p.PartyID 
            WHERE c.ConstituencyID = %s AND c.ElectionID = %s
        """, (constituency_id, election_id))
        
        booths = execute_query("SELECT * FROM Booth WHERE ConstituencyID = %s", (constituency_id,))
        
        return render_template('vote_process.html', voter=voter, candidates=candidates, 
                               election_id=election_id, constituency=constituency, booths=booths)

    # GET: Show Login Form
    elections = execute_query("SELECT * FROM Election WHERE Status = 'Ongoing'")
    return render_template('vote_login.html', elections=elections)

def cast_vote_submit(req):
    voter_id = req.form['voter_id']
    candidate_id = req.form['candidate_id']
    election_id = req.form['election_id']
    constituency_id = req.form['constituency_id']
    booth_id = req.form['booth_id']
    
    # START TRANSACTION (Conceptual - using individual atomic queries/triggers for safety)
    try:
        # 1. Insert Participation (Trigger will check Double Voting)
        execute_query("INSERT INTO VoterParticipation (ElectionID, VoterID, ConstituencyID, BoothID) VALUES (%s, %s, %s, %s)",
                      (election_id, voter_id, constituency_id, booth_id), commit=True)
        
        # 2. Insert Vote
        execute_query("INSERT INTO Vote (ElectionID, ConstituencyID, CandidateID, BoothID) VALUES (%s, %s, %s, %s)",
                      (election_id, constituency_id, candidate_id, booth_id), commit=True)
                      
        flash("Vote Cast Successfully! Thank you.", "success")
        return redirect(url_for('index'))
    except Exception as e:
        flash(f"Error casting vote: {e}", "danger")
        return redirect(url_for('index'))

# ============================
# ANALYTICS & RESULTS
# ============================
@app.route('/results')
def results():
    # Calling Views
    turnout = execute_query("SELECT * FROM View_Election_Turnout")
    party_perf = execute_query("SELECT * FROM View_Party_Performance")
    top_candidates = execute_query("SELECT * FROM View_Candidate_Stats LIMIT 10")
    
    declared_results = execute_procedure('DeclareElectionResults', (1,))
    
    return render_template('results.html', turnout=turnout, party_perf=party_perf, 
                           top_candidates=top_candidates, declared_results=declared_results)

# ============================
# QUERY DASHBOARD
# ============================
@app.route('/queries')
@app.route('/queries/<int:query_id>')
def show_query(query_id=None):
    current_query = None
    results = None
    
    if query_id:
        # Find the query by ID
        current_query = next((q for q in QUERIES if q['id'] == query_id), None)
        if current_query:
            results = execute_query(current_query['sql'])
            
    return render_template('queries.html', queries=QUERIES, current_query=current_query, results=results)

if __name__ == '__main__':
    app.run(debug=True)
