import subprocess
import sys

def run(cmd):
    print(f"Running: {cmd}")
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, shell=True)
    if res.returncode != 0:
        print(f"Failed:\n{res.stdout}")
        sys.exit(1)
    else:
        print(res.stdout)

try:
    run("git add .")
    run("git commit -m \"Commit resolved conflicts\"")
except SystemExit:
    pass # we might not have anything to commit if already clean

branches_to_merge = ["dev-csm", "dev-fugeg", "dev_czz", "dev_lcr"]
for b in branches_to_merge:
    print(f"\n--- Merging {b} ---")
    res = subprocess.run(f"git merge {b} --no-edit", stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, shell=True)
    print(res.stdout)
    if res.returncode != 0:
        print(f"Conflict or error detected while merging {b}. Aborting further merges.")
        with open("merge_error.txt", "w", encoding="utf-8") as f:
            f.write(res.stdout)
        sys.exit(1)

print("All branches merged successfully!")
