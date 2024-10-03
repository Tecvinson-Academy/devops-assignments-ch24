import os
import json

# Load student list
with open("students.json", "r") as f:
    students = json.load(f)["students"]

# Folders to check, which represent the subjects
subjects = ["bash-scripting", "cloud-computing", "docker", "github-actions", "iac", "kubernetes", "monitoring"]

# Initialize the submission status dictionary
# Each student will have a dictionary for each subject's submission status
submission_status = {student: {subject: False for subject in subjects} for student in students}

# Check each folder (subject) for submissions
for subject in subjects:
    if os.path.exists(subject):  # Ensure folder exists
        for file_name in os.listdir(subject):
            for student in students:
                if file_name.startswith(student):
                    submission_status[student][subject] = True

# Generate the table header for README.md
table_header = "| Student | " + " | ".join(subjects) + " |"
table_divider = "| ------- | " + " | ".join(["--------"] * len(subjects)) + " |"

# Generate table rows for each student and their submission statuses per subject
table_rows = "\n".join([
    f"| {student.replace('_', ' ')} | " + " | ".join(['✅' if submission_status[student][subject] else '❌' for subject in subjects]) + " |"
    for student in students
])

table = f"{table_header}\n{table_divider}\n{table_rows}"

# Update the README.md file
with open("README.md", "r") as f:
    readme = f.read()

start_marker = "<!-- SUBMISSION BOARD START -->"
end_marker = "<!-- SUBMISSION BOARD END -->"

# Find existing board section if any
start_index = readme.find(start_marker)
end_index = readme.find(end_marker)

# If a board exists, replace it
if start_index != -1 and end_index != -1:
    readme = readme[:start_index + len(start_marker)] + "\n\n" + table + "\n\n" + readme[end_index:]
else:
    # Otherwise, append the new board
    readme += f"\n\n{start_marker}\n\n{table}\n\n{end_marker}\n"

# Write the updated README.md back
with open("README.md", "w") as f:
    f.write(readme)