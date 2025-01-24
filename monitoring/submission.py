import os
import json
from git import Repo  # Requires GitPython

# Configuration
REPO_PATH = "."  # Path to your Git repository
STUDENTS = [
    "ade_testing", "adeyemi_lawal", "ahmed_omoba", "akinwande_fernandez",
    "blessed_kemka", "chiarasei_tem", "eseoghene_merhe", "festus_okagbare",
    "hassan_oyekunle", "igho_igbini", "ifedayo_osideinde", "joseph_adeniyi",
    "judah_frank", "kelvin_ogedengbe", "luke_nkereawaji", "malarvizhi_raju",
    "michelle_obiorah", "monica_inweh", "oladipupo_olaniyan", "oluwole_precious",
    "otu_valery", "paschal_obeleagu", "rasheedat_mustapha", "ubong_inyang"
]
SUBJECTS = [
    "bash-scripting", "cloud-computing", "docker",
    "github-actions", "iac", "kubernetes", "monitoring"
]

def normalize_name(name):
    """Normalize names to lowercase with underscores"""
    return name.lower().replace('-', '_').replace(' ', '_').replace('.', '_')

def get_student_parts(student):
    """Split student name into normalized first/last name parts"""
    return [normalize_name(part) for part in student.split('_')]

def find_submissions():
    # Initialize submission dictionary
    submissions = {student: {subject: False for subject in SUBJECTS} for student in STUDENTS}
    
    # Check file/directory names
    for subject in SUBJECTS:
        subject_path = os.path.join(REPO_PATH, subject)
        if not os.path.exists(subject_path):
            continue
            
        for entry in os.listdir(subject_path):
            # Remove file extension and normalize
            entry_name = os.path.splitext(entry)[0]
            normalized_entry = normalize_name(entry_name)
            
            # Check against student name parts
            for student in STUDENTS:
                student_parts = get_student_parts(student)
                if any(part in normalized_entry for part in student_parts):
                    submissions[student][subject] = True

    # Check Git commit history
    try:
        repo = Repo(REPO_PATH)
        for commit in repo.iter_commits('HEAD'):
            for item in commit.stats.files:
                subject = item.split('/')[0]
                if subject in SUBJECTS:
                    author = normalize_name(commit.author.name)
                    # Check against student name parts in author name
                    for student in STUDENTS:
                        student_parts = get_student_parts(student)
                        if any(part in author for part in student_parts):
                            submissions[student][subject] = True
    except Exception as e:
        print(f"Could not access Git history: {e}")

    return submissions

def generate_table(submissions):
    # Markdown table header
    table = "| Student \\ Subject | " + " | ".join(SUBJECTS) + " |\n"
    table += "|-------------------|" + "|".join(["---" for _ in SUBJECTS]) + "|\n"
    
    # Table rows
    for student in STUDENTS:
        row = [f"`{student}`"]
        for subject in SUBJECTS:
            row.append("✅" if submissions[student][subject] else "❌")
        table += "| " + " | ".join(row) + " |\n"
    
    return table

if __name__ == "__main__":
    submissions = find_submissions()
    print(generate_table(submissions))
