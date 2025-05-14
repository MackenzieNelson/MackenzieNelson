import json
import sqlite3

print("Starting dump...")

# Load JSON data
with open('AllTheExercise.json', 'r') as file:
    data = json.load(file)

print("Opened file...")

# Connect to SQLite
conn = sqlite3.connect('all_the_exercise.db')
cursor = conn.cursor()

print("Connected to db...")

# Enable foreign keys
cursor.execute("PRAGMA foreign_keys = ON;")

# Insert Category
cursor.execute("INSERT INTO exercise_library (title) VALUES (?)", (data["title"],))
category_id = cursor.lastrowid  # Get category ID

# Insert Programs, Weeks, Days, and Exercises
for program in data["programs"]:
    cursor.execute("INSERT INTO programs (library_id, name) VALUES (?, ?)", (category_id, program["name"]))
    program_id = cursor.lastrowid

    for week_index, week in enumerate(program["weeks"], start=1):
        cursor.execute("INSERT INTO weeks (program_id, week_number) VALUES (?, ?)", (program_id, week_index))
        week_id = cursor.lastrowid

        for day in week["days"]:
            cursor.execute("INSERT INTO days (week_id, name) VALUES (?, ?)", (week_id, day["name"]))
            day_id = cursor.lastrowid

            for exercise in day["exercises"]:
                cursor.execute('''
                    INSERT INTO exercises (day_id, name, reps, rpe, rest, load, warmUpSets, workingSets, notes) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (day_id, exercise["name"], exercise["reps"], exercise["rpe"], exercise["rest"], 
                      exercise["load"], exercise["warmUpSets"], exercise["workingSets"], exercise["notes"]))
                
                exercise_id = cursor.lastrowid

                for substitution in exercise.get("substitutions", []):
                    cursor.execute("INSERT INTO substitutions (exercise_id, substitution_name) VALUES (?, ?)", 
                                   (exercise_id, substitution))

# Commit and close
conn.commit()
conn.close()

print("Database populated successfully!")