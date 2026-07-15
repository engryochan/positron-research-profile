
#!/usr/bin/env python3
from pathlib import Path
import pandas as pd
import shutil

extdir=Path.home()/".positron"/"extensions"
df=pd.read_csv(Path("reports")/"Remove.csv",encoding="utf-8-sig")
count=0
for folder in df["Folder"].astype(str):
    p=extdir/folder
    if p.exists():
        print("Removing",p)
        shutil.rmtree(p,ignore_errors=True)
        count+=1
print("Removed",count,"extensions")
