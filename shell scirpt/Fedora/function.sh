LOG=check.log
result=result.log
> $LOG
> $result

#
# (1) Operating System 
#

function Banner(){
cat << EOF 
  +============================================================================+  
  |                                                                            |
  |                  Linux CentOS 7.x Shell Script Programming                 |
  |                            -  project -                                    |
  |                                                                            |
  |                                                                            |
  |                                                                            |
  +============================================================================+
                                 [ $NUM / 72 ]

EOF
NUM=`expr $NUM + 1`
}

function F_Banner(){
cat << EOF 
  +============================================================================+    
  |                                                                            |
  |                  Linux CentOS 7.x Shell Script Programming                 |
  |                              team [ONE-J]                                  |
  |                                                                            |
  |                                                                            |
  |                                                                            |
  +============================================================================+
                                  [ Finish ]
                             [ check report.txt ]

EOF
}


#
# (2) for All ===============================================================================
#

BAR() {
echo "========================================================================" >> $result
}

NOTICE() {
echo '[ OK ] : 정상'
echo '[WARN] : 비정상'
echo '[INFO] : Information 파일을 보고, 고객과 상의'
}

OK() {
echo -e '\033[32m'"[ 양호 ] : $*"'\033[0m'
} >> $result

WARN() {
echo -e '\033[31m'"[ 취약 ] : $*"'\033[0m'
} >> $result

INFO() { 
echo -e '\033[35m'"[ 정보 ] : $*"'\033[0m'
} >> $result

CODE(){
echo -e '\033[36m'$*'\033[0m' 
} >> $result

SCRIPTNAME() {
basename $0 | awk -F. '{print $1}' 
}

#
# (3) for Some ==================================================================================
#

FindPatternReturnValue() {
# $1 : File name
# $2 : Find Pattern
if egrep -v '^#|^$' $1 | grep -q $2 ; then # -q = 출력 내용 없도록
	ReturnValue=$(egrep -v '^#|^$' $1 | grep $2 | awk -F= '{print $2}')
else
	ReturnValue=None
fi
echo $ReturnValue
}

IsFindPattern() {
if egrep -v '^#|^$' $1 | grep -q $2 ; then # 라인의 처음이#, 라인의 처음이 마지막으로 되어있는
	ReturnValue=$?
else
	ReturnValue=$?
fi
echo $ReturnValue
}

PAM_FindPatternReturnValue() {
PAM_FILE=$1
PAM_MODULE=$2
PAM_FindPattern=$3
LINE=$(egrep -v '^#|^$' $PAM_FILE | grep $PAM_MODULE)
if [ -z "$LINE" ] ; then #내용이 없으면 (zero면) None을 출력
	ReturnValue=None
else
	PARAMS=$(echo $LINE | cut -d ' ' -f4-)
	# echo $PARAMS
	set $PARAMS
	while [ $# -ge 1 ]
	do
		CHOICE1=$(echo $* | awk '{print $1}' | awk -F= '{print $1}')
		CHOICE2=$(echo $* | awk '{print $1}' | awk -F= '{print $2}')
		# echo "$CHOICE1 : $CHOICE2"
		case $CHOICE1 in
			$PAM_FindPattern) ReturnValue=$CHOICE2 ;;
			*) : ;;		
		esac
		shift
	done
fi
echo $ReturnValue

CheckEncryptedPasswd() {
SFILE=$1
# $1$saltkey$encrypted 숫자들은 암호화 알고리즘의 종류
# $2a$saltkey$encrypted
# $5$saltkey$encrypted
# $6$saltkey$encrypted 우리는 6번을 써야함
EncryptedPasswdField=$(grep '^root' $SFILE | awk -F: '{print $2}' | awk -F'$' '{print $2}')
#echo $EncryptedPasswdField
case $EncryptedPasswdField in
	1|2a|5) echo WarnTrue ;;
	6) echo TrueTrue ;;
	*) echo 'None' ;;
esac
}

#	1) echo "암호화 방식 : MD5" ;; # 메뉴얼 확인 : man 5 shadow ; man 3 crypt
#	2a) echo "암호화 방식 : Blowfish" ;;
#	5) echo "암호화 방식 : SHA-256" ;;
#	6) echo "암호화 방식 : SHA-512" ;;
#	*) echo "암호화 방식 : None" ;;

SearchValue() {

SEARCH=$(egrep -v '^#|^$' $2 | sed 's/#.*//' | grep -w $3)
if [ -z "$SEARCH" ] ; then
	echo FALSE
else
	if [ $1 = 'KEYVALUE' ] ; then
	echo $SEARCH
elif [ $1 = 'VALUE' ] ; then
	echo "$SEARCH" | awk '{print $2}'
	fi
fi
}
}