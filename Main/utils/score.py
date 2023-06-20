import os

def return_score(folder_path):
    local_folder_path = os.path.join(folder_path, "txt")

    with open(os.path.join(local_folder_path, "Score", "AScore.txt"), "r", encoding="ANSI") as f:
        Ascore = int(f.read())
    AscorePer = round((Ascore / 147) * 100, 2)

    with open(os.path.join(local_folder_path, "Score", "SScore.txt"), "r", encoding="ANSI") as f:
        Sscore = int(f.read())
    SscorePer = round((Sscore / 348) * 100, 2)

    with open(os.path.join(local_folder_path, "Score", "PScore.txt"), "r", encoding="ANSI") as f:
        Pscore = int(f.read())
    PscorePer = round((Pscore / 9) * 100, 2)

    with open(os.path.join(local_folder_path, "Score", "LScore.txt"), "r", encoding="ANSI") as f:
        Lscore = int(f.read())
    LscorePer = round((Lscore / 27) * 100, 2)

    with open(os.path.join(local_folder_path, "Score", "SeScore.txt"), "r", encoding="ANSI") as f:
        Sescore = int(f.read())
    SescorePer = round((Sescore / 168) * 100, 2)

    return AscorePer, SscorePer, PscorePer, LscorePer, SescorePer

print("작업 종료")