import mysql.connector
from app.db import DB_CONFIG

def verify():
    print("Connecting...")
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        
        # 1. Check Views
        print("Checking View_Election_Turnout...")
        cursor.execute("SELECT * FROM View_Election_Turnout LIMIT 1")
        cursor.fetchall()
        print("View_Election_Turnout exists.")
        
        # 2. Check Procedure
        print("Checking DeclareElectionResults...")
        try:
            cursor.callproc('DeclareElectionResults', (1,))
            print("Procedure DeclareElectionResults call successful.")
            # Consume results to be clean
            for res in cursor.stored_results():
                res.fetchall()
        except Exception as e:
            print(f"Procedure Failed: {e}")
            
    except mysql.connector.Error as err:
        print(f"DB Error: {err}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    verify()
