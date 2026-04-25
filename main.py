#!/usr/bin/env python3
# main.py
import os
import subprocess
import platform
import datetime
import json
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
from rich.live import Live
from rich.logging import RichHandler
import logging

# 콘솔 설정
console = Console()

# 로고 정의
BANNER = """
[bold cyan]
   ___         _   _                      _ _   _ 
  / _ \ _ __  | |_(_) __ _ _ __ __ ___ _(_) |_| |_  
 / /_\ \ '_ \ | __| |/ _` | '__/ _` \ \ / | __|   / 
/ /_\\ \ | | || |_| | (_| | | | (_| |>  <| | |_| |\\  
\____/ |_| |_| \__|_|\__, |_|  \__,_/_/\_\_|\__|_| \\_\\
                     |___/                            
[/bold cyan]
[bold white]Antigravity Infrastructure Security Scanner v2.0[/bold white]
"""

class VulnScanner:
    def __init__(self):
        self.os_profile = self._detect_os()
        self.hostname = platform.node()
        self.start_time = datetime.datetime.now()
        self.results = []
        self.stats = {"양호": 0, "취약": 0, "N/A": 0}
        
    def _detect_os(self):
        if os.path.exists("/etc/os-release"):
            with open("/etc/os-release") as f:
                lines = f.readlines()
                for line in lines:
                    if line.startswith("ID="):
                        os_id = line.split("=")[1].strip().replace('"', '')
                        if os_id == "ubuntu": return "ubuntu"
                        if os_id in ["centos", "rhel"]: return "centos"
                        if os_id in ["ol", "oracle"]: return "oracle"
        return "ubuntu" # 기본값

    def run_diagnostics(self):
        script_dir = f"shell_script/{self.os_profile}"
        scripts = [f"U-{i:02d}.sh" for i in range(1, 73)]
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            BarColumn(bar_width=40),
            TaskProgressColumn(),
            console=console,
        ) as progress:
            task = progress.add_task("[cyan]보안 진단 수행 중...", total=len(scripts))
            
            for script_name in scripts:
                script_path = os.path.join(script_dir, script_name)
                if os.path.exists(script_path):
                    progress.update(task, description=f"[yellow]진단 중: {script_name}")
                    
                    try:
                        # 스크립트 실행 및 결과 캡처
                        res = subprocess.run(["bash", script_path], capture_output=True, text=True)
                        output = res.stdout
                        
                        # 결과 판별 (Markdown 테이블에서 추출)
                        result_val = "N/A"
                        if "**양호**" in output: 
                            result_val = "양호"
                            self.stats["양호"] += 1
                        elif "**취약**" in output: 
                            result_val = "취약"
                            self.stats["취약"] += 1
                        
                        self.results.append({
                            "code": script_name.replace(".sh", ""),
                            "result": result_val,
                            "output": output
                        })
                    except Exception as e:
                        logging.error(f"Error running {script_name}: {e}")
                
                progress.advance(task)

    def generate_reports(self):
        date_str = self.start_time.strftime("%Y%m%d_%H%M%S")
        report_dir = "reports"
        os.makedirs(report_dir, exist_ok=True)
        
        # 1. Markdown 리포트
        md_path = f"{report_dir}/Result_{self.hostname}_{date_str}.md"
        with open(md_path, "w", encoding="utf-8") as f:
            f.write(f"# 보안 진단 통합 리포트 ({self.hostname})\n\n")
            f.write(f"| 진단일시 | OS 프로필 | 양호 | 취약 |\n")
            f.write(f"|----------|-----------|------|------|\n")
            f.write(f"| {self.start_time.strftime('%Y-%m-%d %H:%M:%S')} | {self.os_profile} | {self.stats['양호']} | {self.stats['취약']} |\n\n---\n")
            
            for res in self.results:
                f.write(res["output"] + "\n")
                
        # 2. JSON 데이터
        json_path = f"{report_dir}/Result_{self.hostname}_{date_str}.json"
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump({
                "metadata": {
                    "hostname": self.hostname,
                    "os": self.os_profile,
                    "timestamp": self.start_time.isoformat()
                },
                "stats": self.stats,
                "details": self.results
            }, f, ensure_ascii=False, indent=4)
            
        return md_path, json_path

    def show_summary(self, md_path):
        table = Table(title="[bold white]보안 진단 결과 요약[/bold white]", show_header=True, header_style="bold magenta")
        table.add_column("항목", style="dim")
        table.add_column("수치", justify="right")
        table.add_column("비율", justify="right")
        
        total = sum(self.stats.values())
        if total == 0: total = 1
        
        table.add_row("양호 (Good)", f"[bold green]{self.stats['양호']}[/bold green]", f"{self.stats['양호']/total*100:.1f}%")
        table.add_row("취약 (Vulnerable)", f"[bold red]{self.stats['취약']}[/bold red]", f"{self.stats['취약']/total*100:.1f}%")
        table.add_row("진단 미수행 (N/A)", f"{self.stats['N/A']}", f"{self.stats['N/A']/total*100:.1f}%")
        
        console.print("\n")
        console.print(Panel(table, border_style="cyan"))
        console.print(f"\n[bold green]✔[/bold green] 통합 리포트가 생성되었습니다: [blue underline]{md_path}[/blue underline]\n")

def main():
    console.print(BANNER)
    
    scanner = VulnScanner()
    console.print(f"[bold blue]ℹ[/bold blue] 호스트: [white]{scanner.hostname}[/white] | 프로필: [bold yellow]{scanner.os_profile}[/bold yellow]")
    
    scanner.run_diagnostics()
    md_path, json_path = scanner.generate_reports()
    scanner.show_summary(md_path)

if __name__ == "__main__":
    main()
