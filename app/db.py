import mysql.connector
from flask import g

DB_CONFIG = {
    'user': 'root',     
    'password': 'risgov123',  
    'host': 'localhost',
    'database': 'ElectionSystem'
}

def get_db():
    if 'db' not in g:
        try:
            g.db = mysql.connector.connect(**DB_CONFIG)
        except mysql.connector.Error as err:
            print(f"Error: {err}")
            return None
    return g.db

def close_db(e=None):
    db = g.pop('db', None)
    if db is not None:
        db.close()

# Core Data Access Functions

def execute_query(query, params=None, fetch_one=False, commit=False):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        if commit:
            conn.commit()
            return cursor.lastrowid
        
        if fetch_one:
            return cursor.fetchone()
        return cursor.fetchall()
    except Exception as e:
        print(f"Query Error: {e}")
        return None
    finally:
        cursor.close()

def execute_procedure(proc_name, args=()):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.callproc(proc_name, args)
        # For fetching results from procedure
        results = []
        for result in cursor.stored_results():
            results.extend(result.fetchall())
        return results
    except Exception as e:
        print(f"Procedure Error: {e}")
        return None
    finally:
        cursor.close()
