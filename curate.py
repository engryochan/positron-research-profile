#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Positron Research Profile - curate.py v1.5
"""
from pathlib import Path
from collections import defaultdict
from time import perf_counter
import argparse,csv,re

try:
    from rich.progress import Progress
    RICH=True
except Exception:
    RICH=False

EXT_DIR=Path.home()/".positron"/"extensions"
REPORT_DIR=Path("reports"); REPORT_DIR.mkdir(exist_ok=True)
PATTERN=re.compile(r"^(.*?)-((\d+\.)+\d+.*)$")

def folder_size(p:Path)->int:
    total=0
    for f in p.rglob("*"):
        try:
            if f.is_file():
                total+=f.stat().st_size
        except Exception:
            pass
    return total

def parse(name:str):
    m=PATTERN.match(name)
    return (m.group(1),m.group(2)) if m else (name,"")

def scan():
    if not EXT_DIR.exists():
        raise SystemExit(f"找不到目录：{EXT_DIR}")
    dirs=sorted([d for d in EXT_DIR.iterdir() if d.is_dir()])
    exts=[]; dup=defaultdict(list)
    if RICH:
        with Progress() as progress:
            t=progress.add_task("扫描扩展...", total=len(dirs))
            for d in dirs:
                b,v=parse(d.name); s=folder_size(d)
                dup[b].append(v)
                exts.append({"Extension":b,"Version":v,"Folder":d.name,
                             "SizeMB":round(s/1024/1024,2),
                             "SizeGB":round(s/1024/1024/1024,3)})
                progress.advance(t)
    else:
        total=len(dirs)
        for i,d in enumerate(dirs,1):
            print(f"\r[{i}/{total}] {i/total*100:5.1f}% {d.name[:40]}",end="",flush=True)
            b,v=parse(d.name); s=folder_size(d)
            dup[b].append(v)
            exts.append({"Extension":b,"Version":v,"Folder":d.name,
                         "SizeMB":round(s/1024/1024,2),
                         "SizeGB":round(s/1024/1024/1024,3)})
        print()
    return exts,dup

def export(exts,dup,top):
    exts.sort(key=lambda x:x["SizeMB"],reverse=True)
    with open(REPORT_DIR/"Research_Profile.csv","w",newline="",encoding="utf-8-sig") as f:
        w=csv.DictWriter(f,fieldnames=exts[0].keys());w.writeheader();w.writerows(exts)
    with open(REPORT_DIR/"Duplicate.csv","w",newline="",encoding="utf-8-sig") as f:
        w=csv.writer(f);w.writerow(["Extension","Versions"])
        for k,v in dup.items():
            if len(v)>1:w.writerow([k,", ".join(v)])
    with open(REPORT_DIR/"Large.csv","w",newline="",encoding="utf-8-sig") as f:
        w=csv.DictWriter(f,fieldnames=exts[0].keys());w.writeheader()
        for e in exts:
            if e["SizeMB"]>=200:w.writerow(e)
    with open(REPORT_DIR/"Research_Report.md","w",encoding="utf-8") as md:
        md.write("# Positron Research Report\n\n")
        md.write(f"扩展数量：**{len(exts)}**\n\n")
        md.write("|Extension|Version|SizeGB|\n|---|---|---:|\n")
        for e in exts[:top]:
            md.write(f"|{e['Extension']}|{e['Version']}|{e['SizeGB']}|\n")

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--top",type=int,default=30)
    args=ap.parse_args()
    t0=perf_counter()
    exts,dup=scan()
    export(exts,dup,args.top)
    elapsed=perf_counter()-t0
    total=sum(x["SizeGB"] for x in exts)
    print(f"\n扩展数量: {len(exts)}")
    print(f"重复扩展: {sum(1 for v in dup.values() if len(v)>1)}")
    print(f"总容量: {total:.2f} GB")
    print(f"耗时: {elapsed:.1f} 秒")
    print(f"报告目录: {REPORT_DIR.resolve()}")

if __name__=="__main__":
    main()
