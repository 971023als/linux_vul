import os
import re

def patch_vul_sh(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Target pattern: RESULT=$(python3 "$SCRIPT_PATH" 2>>"$ERRORS_PATH")
    # Replacement pattern: RESULT=$(bash ../../runners/shell_runner.sh --check "U-$i" --script "$SCRIPT_PATH")
    
    target = r'RESULT=\$\(python3 "\$SCRIPT_PATH" 2>>"\$ERRORS_PATH"\)'
    replacement = r'RESULT=$(bash ../../runners/shell_runner.sh --check "U-$i" --script "$SCRIPT_PATH")'
    
    new_content = re.sub(target, replacement, content)
    
    if content != new_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Patched: {file_path}")
    else:
        print(f"No match found in: {file_path}")

def main():
    base_dir = "shell_script"
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file == "vul.sh":
                patch_vul_sh(os.path.join(root, file))

if __name__ == "__main__":
    main()
