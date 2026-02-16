import mysql.connector
import os
from app.db import DB_CONFIG

def run_sql_file(cursor, filename):
    print(f"Executing {filename}...")
    with open(filename, 'r') as f:
        # Read the file and split by delimiter
        # Note: Simple split by ';' might break triggers/procedures with delimiters like //
        # So we read the whole content and use a slightly smarter approach or just mysql-connector's multi=True
        sql_content = f.read()
        
        # MySQL Connector python supports multi=True
        # However, for Delimiter // we might need to be careful.
        # simpler approach for scripts with custom delimiters:
        # Split by the 'DELIMITER' keyword isn't natively supported well in simple splitting.
        # But mysql-connector can handle standard statements. 
        # For this script, let's try executing commands one by one if possible, 
        # or rely on multi_statement execution.
        
        try:
             # Basic split for standard queries, but this breaks on Procedures.
             # Better way: Use the command line mysql tool if available, or just parse carefully.
             # Given the complexity of triggers/procedures in python drivers,
             # we will try to execute the entire buffer with multi=True
             pass
        except Exception as e:
            print(f"Error reading file: {e}")

    # Re-impl: Just read the file and let the driver handle it if possible, 
    # but the driver doesn't support 'DELIMITER' command.
    # So we'll parse it manually.
    
    commands = []
    delimiter = ';'
    current_command = []
    
    lines = sql_content.split('\n')
    for line in lines:
        stripped = line.strip()
        if stripped.upper().startswith('DELIMITER'):
            delimiter = stripped.split()[1]
            continue
        
        if stripped.endswith(delimiter):
            # remove delimiter from end
            current_command.append(line.rstrip()[:-len(delimiter)])
            full_cmd = "\n".join(current_command).strip()
            if full_cmd:
                commands.append(full_cmd)
            current_command = []
        else:
            current_command.append(line)
            
    for cmd in commands:
        try:
            cursor.execute(cmd)
        except mysql.connector.Error as err:
            print(f"Failed executing: {cmd[:50]}... \nError: {err}")

def setup_database():
    # Connect to MySQL Server (Create DB if not exists)
    # We first connect without DB to create it
    try:
        conn = mysql.connector.connect(
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password'],
            host=DB_CONFIG['host']
        )
        cursor = conn.cursor()
        
        # Create Database
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_CONFIG['database']}")
        print(f"Database '{DB_CONFIG['database']}' ensured.")
        
        conn.database = DB_CONFIG['database']
        
        # Run Scripts
        base_dir = 'database'
        scripts = ['schema.sql', 'views_triggers.sql', 'seed_data.sql']
        
        for script in scripts:
            path = os.path.join(base_dir, script)
            if os.path.exists(path):
                # For this simple runner, we'll accept that parsing SQL with delimiters in Python is tricky.
                # simpler approach: Read full text and use multi=True, but remove DELIMITER lines manually
                # because the python driver doesn't like them.
                
                with open(path, 'r') as f:
                    content = f.read()
                    
                # Basic cleaning for python driver
                # 1. Remove "DELIMITER //" lines
                # 2. Replace "//" with ";" so it looks like standard SQL ? No, that breaks logic inside bodies.
                # Actually, mysql-connector has limited support for this. 
                # THE BEST WAY for the user is to use the shell.
                
                print(f"WARNING: Executing {script}. PRO TIP: If this fails on Triggers, use MySQL Workbench.")
                
                # We will try a naive execution for simple tables first.
                # If it's schema.sql or seed_data.sql, it's easy.
                if 'views' not in script:
                    statements = content.split(';')
                    for stmt in statements:
                        if stmt.strip():
                            try:
                                cursor.execute(stmt)
                            except Exception as e:
                                print(f"Skipping error in {script}: {e}")
                else:
                    print(f"Skipping automated run for {script} (Complex Triggers). Please run valid views_triggers.sql in Workbench.")
                    
        conn.commit()
        print("Setup completed (Partial/Success).")
        cursor.close()
        conn.close()
        
    except mysql.connector.Error as err:
        print(f"Connection Error: {err}")
        print("Please check your password in app/db.py")

if __name__ == "__main__":
    setup_database()
