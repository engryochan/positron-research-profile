
#!/usr/bin/env python3
from pathlib import Path
import pandas as pd

REPORTS=Path("reports")
inp=REPORTS/"Research_Profile.csv"
out=REPORTS/"Classified.csv"

RULES={
"Theme":["theme","icon","color","material","darcula"],
"Snippet":["snippet"],
"AI":["copilot","chatgpt","claude","continue","gemini","codegenie","jetro","triplex","cannbot","openai"],
"Python":["python","pylance","ruff","black"],
"R":["quarto","reditorsupport",".r"],
"Docker":["docker","container","devcontainer"],
"Database":["sql","duckdb","postgres","mysql","sqlite"],
}

df=pd.read_csv(inp,encoding="utf-8-sig")
cats=[]
for ext in df["Extension"].astype(str):
    e=ext.lower(); c="Other"
    for k,vals in RULES.items():
        if any(v in e for v in vals):
            c=k; break
    cats.append(c)
df["Category"]=cats
df.to_csv(out,index=False,encoding="utf-8-sig")
print("Saved:",out)
