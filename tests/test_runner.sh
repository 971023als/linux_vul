#!/bin/bash
# test_runner.sh
# Purpose: Verify that runners/shell_runner.sh captures evidence correctly

echo "Running Harness Test..."

# Create a dummy audit script
cat <<EOF > test_audit.sh
#!/bin/bash
echo '{"id": "U-TEST", "status": "PASS", "message": "Harness works"}'
EOF
chmod +x test_audit.sh

# Run the runner
bash runners/shell_runner.sh --check U-TEST --script ./test_audit.sh

# Check results
if [ -f "output/evidence/U-TEST/stdout.txt" ] && [ "$(cat output/evidence/U-TEST/stdout.txt)" == '{"id": "U-TEST", "status": "PASS", "message": "Harness works"}' ]; then
    echo "SUCCESS: Harness captured stdout correctly."
else
    echo "FAILURE: Harness stdout capture failed."
    exit 1
fi

if [ -f "output/evidence/U-TEST/exit_code.txt" ] && [ "$(cat output/evidence/U-TEST/exit_code.txt)" == "0" ]; then
    echo "SUCCESS: Harness captured exit code correctly."
else
    echo "FAILURE: Harness exit code capture failed."
    exit 1
fi

rm test_audit.sh
echo "Harness Test Passed."
