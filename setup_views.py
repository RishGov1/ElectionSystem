import mysql.connector
import os
from app.db import DB_CONFIG

def setup_views():
    print("Connecting to database...")
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    filepath = os.path.join('database', 'views_triggers.sql')
    print(f"Reading {filepath}...")
    
    with open(filepath, 'r') as f:
        lines = f.readlines()

    delimiter = ';'
    buffer = []

    print("Executing statements...")
    for line in lines:
        stripped = line.strip()
        
        # Skip empty lines and comments (if they start the line)
        if not stripped or stripped.startswith('--'):
            continue

        # Handle Delimiter Change
        if stripped.upper().startswith('DELIMITER'):
            delimiter = stripped.split()[1]
            continue
            
        buffer.append(line)
        
        # Check if the stripped line ends with the delimiter
        if stripped.endswith(delimiter):
            # Join buffer to form full statement
            statement = "".join(buffer).strip()
            
            # Remove the delimiter from the end
            # We use rstrip to handle potential trailing newlines/spaces in the buffer join ??
            # Actually, we processed lines. 
            # safe removal:
            if statement.endswith(delimiter):
                statement = statement[:-len(delimiter)].strip()
            
            if statement:
                try:
                    cursor.execute(statement)
                    # print(f"Executed command starting with: {statement[:30]}...")
                except mysql.connector.Error as err:
                    print(f"Failed to execute:\n{statement}\nError: {err}\n")
            
            buffer = []

    conn.commit()
    cursor.close()
    conn.close()
    print("Views, Triggers, and Procedures setup completed.")

if __name__ == "__main__":
    setup_views()
