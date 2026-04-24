#!/bin/bash
# This script collects server statistics and report.

DIVIDER="========================================"

print_section() {
    echo ""
    echo "$DIVIDER"
    echo "  $1"
    echo "$DIVIDER"
}

tab_echo() {
    echo "  "
}

echo ""
echo " Server Performance Report"
echo " Generated on: $(date)"

## CPU 부분

# 함수 실행
print_section "CPU USAGE"

CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d '%')
CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)
# 배포판 호환성이 높은 방법
# CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1}')

echo "  Total CPU Usage : $CPU_USAGE%"

## 메모리 부분

print_section "MEMORY USAGE"

# Mem: 으로 시작하는 줄을 필터링해서, 각 칼럼을 출력
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}');
USED_MEM=$(free -m | awk '/^Mem:/{print $3}')
FREE_MEM=$(free -m | awk '/^Mem:/{print $4}')
MEM_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($USED_MEM/$TOTAL_MEM)*100}");

echo "  Total   : ${TOTAL_MEM} MB"
echo "  Total   : ${USED_MEM} MB (${MEM_PERCENT}%)"
echo "  Total   : ${FREE_MEM} MB"

## 디스크 사용량 구현

print_section "DISK USAGE"

df -h | grep -v "tmpfs" | awk '{printf "  %-20s %-6s %-6s %-6s %-5s %s\n", $1,$2,$3,$4,$5,$6}'
echo ""
df -h --total | awk '/total/{printf "  [Total] Used: %s / %s (%s used), Free: %s\n", $3, $2, $5, $4}'

print_section "TOP 5 PROCESSES BY CPU"

printf "  %-10s %-8s %-8s %s\n" "PID" "CPU%" "MEM%" "COMMAND"
echo "  ----------------------------------------"

ps aux --sort=-%cpu | awk 'NR>1 && NR<=6 {
    printf "  %-10s %-8s %-8s %s\n", $2, $3, $4, $11
}'

print_section "TOP 5 PROCESSES BY MEMORY"

printf "  %-10s %-8s %-8s %s\n" "PID" "CPU%" "MEM%" "COMMAND"
echo "  ----------------------------------------"

ps aux --sort=-%mem | awk 'NR>1 && NR<=6 {
    printf "  %-10s %-8s %-8s %s\n", $2, $3, $4, $11
}'

print_section "SYSTEM INFO"

# OS 버전
echo "  OS      : $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"

# 업타임
echo "  Uptime  : $(uptime -p)"

# 로드 평균 (1분, 5분, 15분)
LOAD=$(uptime | awk -F'load average:' '{print $2}')
echo "  Load Avg:$LOAD"

# 현재 로그인 유저
echo "  Users   : $(who | wc -l) logged in"

# 실패한 로그인 시도 (root 권한 필요할 수 있음)
FAILED=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
echo "  Failed Login Attempts: ${FAILED}"
