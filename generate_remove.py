
#!/usr/bin/env python3
from pathlib import Path
import pandas as pd

r=Path("reports")
df=pd.read_csv(r/"Classified.csv",encoding="utf-8-sig")
keep={"AI","Python","R","Docker","Database"}
remove=df[df["Category"].isin(["Theme","Snippet"])]
review=df[(~df["Category"].isin(keep)) & (~df["Category"].isin(["Theme","Snippet"]))]
keepdf=df[df["Category"].isin(keep)]
keepdf.to_csv(r/"Keep.csv",index=False,encoding="utf-8-sig")
remove.to_csv(r/"Remove.csv",index=False,encoding="utf-8-sig")
review.to_csv(r/"Review.csv",index=False,encoding="utf-8-sig")
print("Generated Keep/Remove/Review")
