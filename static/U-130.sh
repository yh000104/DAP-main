#!/bin/bash

mkdir -p U1~73/log
mkdir -p U1~73/action
mkdir -p U1~73/bad
mkdir -p U1~73/good

##########[U-01]root 계정 원격 접속 제한##########

echo -e "\n=====================================================================================================================================\n[U-01] root 계정 원격 접속 제한\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-01] root 계정 원격 접속 제한\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-01] root 계정 원격 접속 제한" >> U1~73/action.txt
#log 파일에서 구분선 앞에 한칸을 띄고, 제목 뒤로 개행을 한번 더 해서 공간 확보, 나머지 inspect, action은 최대한 한눈에 보이도록 정리

CF1=/etc/securetty
CF2=/etc/pam.d/login
pts=$(grep 'pts' $CF1 | grep -v '#')
pam=$(grep "/lib/security/pam_securetty.so" $CF2 | grep 'required' | awk '{print $1}')
#사용할 변수 선언

echo -e "[root 직접접속 차단 여부]" >> U1~73/log/[U-01]log.txt
grep 'pts' $CF1 >> U1~73/log/[U-01]log.txt
echo -e "\n[원격 터미널 서비스 사용 여부]" >> U1~73/log/[U-01]log.txt
grep '/lib/security/pam_securetty.so' $CF2 | grep 'required' | grep 'auth' >> U1~73/log/[U-01]log.txt
#로그파일에 출력에 대한 제목후 개행하여 길어도 보기 편하게 출력

cat U1~73/log/[U-01]log.txt >> U1~73/log.txt


if [[ $pam == 'auth' ]] || [[ -z $pts ]]; then
 echo -e "[U-01] 원격 터미널 서비스를 사용하지 않거나, 사용 시 root 직접 접속을 차단되어 있음 - [양호]" >> U1~73/good/[U-01]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-01]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-01] 원격 터미널 서비스 사용 시 root 직접 접속이 허용되어 있음 - [취약]" >> U1~73/bad/[U-01]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-01]bad.txt >> U1~73/inspect.txt
 echo -e "[U-01] vi 편집기를 사용하여 /etc/securetty 파일을 열어 pts/* 설정이 존재하는 경우 제거 또는 주석처리\nvi 편집기를 사용하여 /etc/pam.d/login 파일을 열어 auth required /lib/security/pam_securetty.so 설정이 없거나 주석처리 되어 있다면 신규 삽입 또는 주석 제거" >> U1~73/action/[U-01]action.txt
 sed -e 's/\[U-01\] /\n\[조치사항\]\n/g' U1~73/action/[U-01]action.txt >> U1~73/action.txt
fi

##########[U-02]패스워드 복잡성 설정##########

echo -e "\n=====================================================================================================================================\n[U-02] 패스워드 복잡성 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-02] 패스워드 복잡성 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-02] 패스워드 복잡성 설정" >> U1~73/action.txt

CF1=/etc/pam.d/system-auth
CF2=/etc/login.defs

lcredit=$(grep "pam_cracklib.so" $CF1 | tr -s ' ' '\n' | grep lcredit | awk -F= '{print $2}')
ucredit=$(grep "pam_cracklib.so" $CF1 | tr -s ' ' '\n' | grep ucredit | awk -F= '{print $2}')
dcredit=$(grep "pam_cracklib.so" $CF1 | tr -s ' ' '\n' | grep dcredit | awk -F= '{print $2}')
ocredit=$(grep "pam_cracklib.so" $CF1 | tr -s ' ' '\n' | grep ocredit | awk -F= '{print $2}')
retry=$(grep "pam_cracklib.so" $CF1 | tr -s ' ' '\n' | grep retry | awk -F= '{print $2}')
minlen=$(grep "pam_cracklib.so" $CF1 | tr -s ' ' '\n' | grep minlen | awk -F= '{print $2}')
age=$(grep -i "pass" $CF2 | grep -v "#" | grep -i 'warn_age' | awk '{print $2}')
max_day=$(grep -i "pass" $CF2 | grep -v "#" | grep -i 'max_days' | awk '{print $2}')
min_day=$(grep -i "pass" $CF2 | grep -v "#" | grep -i 'min_days' | awk '{print $2}')
min_len=$(grep -i "pass" $CF2 | grep -v "#" | grep -i 'min_len' | awk '{print $2}')

echo -e "[/etc/pam.d/system-auth 파일 설정]" >> U1~73/log/[U-02]log.txt
grep "pam_cracklib.so" $CF1 | tr -s ' ' '\n' | sed '1,3d' >> U1~73/log/[U-02]log.txt
echo -e "\n[/etc/login.defs 파일설정]" >> U1~73/log/[U-02]log.txt
grep -i 'pass' /etc/login.defs | grep -v '#' >> U1~73/log/[U-02]log.txt

cat U1~73/log/[U-02]log.txt >> U1~73/log.txt


if [[ $lcredit == -1 ]] && [[ $ucredit == -1 ]] && [[ $dcredit == -1 ]] && [[ $ocredit == -1 ]] && [[ $minlen -ge 8 ]] && [[ $retry == 3 ]] && [[ $age == 7 ]] && [[ $min_day -ge 1 ]] && [[ $max_day -le 60 ]] && [[ $min_len -ge 8 ]]; then
 echo -e "[U-02] /etc/pam.d/system-auth, /etc/login.defs 내용이 내부 정책에 맞도록 설정되어있음 - [양호]" >> U1~73/good/[U-02]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-02]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-02] /etc/pam.d/system-auth, /etc/login.defs 내용이 내부 정책에 맞도록 설정되어 있지 않음 - [취약]" >> U1~73/bad/[U-02]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-02]bad.txt >> U1~73/inspect.txt
 echo -e "[U-02] vi 편집기로 /etc/pam.d/system-auth 파일을 열어\n retry=3 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1로 설정\nvi 편집기로 /etc/login.defs 파일을 열어\n pass_warn_age=7, pass_max_day=60, pass_min_day=1, pass_min_len=8로 설정 변경" >> U1~73/action/[U-02]action.txt
 sed -e 's/\[U-02\] /\n\[조치사항\]\n/g' U1~73/action/[U-02]action.txt >> U1~73/action.txt

fi

##########[U-03]계정 잠금 임계값 설정##########


echo -e "\n=====================================================================================================================================\n[U-03] 계정 잠금 임계값 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-03] 계정 잠금 임계값 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-03] 계정 잠금 임계값 설정" >> U1~73/action.txt

CF=/etc/pam.d/system-auth
DENY=$(grep -i "deny=" $CF | grep -v '#' | awk '{print $4}' | awk -F= '{if($2<6)print($0)}')

echo -e "[계정 잠금 임계값]" >> U1~73/log/[U-03]log.txt ; grep "deny=" /etc/pam.d/system-auth | grep -v '#' | awk '{print $4}' >> U1~73/log/[U-03]log.txt
cat U1~73/log/[U-03]log.txt >> U1~73/log.txt


if [[ -n $DENY ]]; then
 echo -e "[U-03] 계정 잠금 임계값이 5이하의 값으로 설정되어 있음 - [양호]" >> U1~73/good/[U-03]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-03]good.txt >> U1~73/inspect.txt

else
 echo -e "[U-03] 계정 잠금 임계값이 설정되어 있지 않거나, 5 이하의 값으로 설정되지 않음 - [취약]" >> U1~73/bad/[U-03]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-03]bad.txt >> U1~73/inspect.txt

 echo -e "[U-03] 계정 잠금 임계값을 5 이하로 설정\n deny 값을 5 이하의 값으로 설정" >> U1~73/action/[U-03]action.txt
 sed -e 's/\[U-03\] /\n\[조치사항\]\n/g' U1~73/action/[U-03]action.txt >> U1~73/action.txt

fi

##########[U-04]패스워드 파일 보호##########


echo -e "\n=====================================================================================================================================\n[U-04] 패스워드 파일 보호\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-04] 패스워드 파일 보호\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-04] 패스워드 파일 보호" >> U1~73/action.txt

SD=/etc/shadow
PW=$(cat /etc/passwd | awk -F: '{if($2 != "x")print ($2)}')

echo -e "[shadow 파일 존재 확인]" >> U1~73/log/[U-04]log.txt
ls /etc | grep "shadow" >> U1~73/log/[U-04]log.txt
echo -e "\n[패스워드 암호화 되지 않은 파일 확인]" >> U1~73/log/[U-04]log.txt
$PW >> U1~73/log/[U-04]log.txt

cat U1~73/log/[U-04]log.txt >> U1~73/log.txt


if [[ ! -e $SD ]] && [[ -n $PW ]]; then
 echo -e "[U-04] 쉐도우 패스워드를 사용하지 않고, 패스워드를 암호화하여 저장하지 않음 - [취약]" >> U1~73/bad/[U-04]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-04]bad.txt >> U1~73/inspect.txt

 echo -e "[U-04] #pwconv 명령어를 사용하여 쉐도우 패스워드 정책 적용" >> U1~73/action/[U-04]action.txt
 sed -e 's/\[U-04\] /\n\[조치사항\]\n/g' U1~73/action/[U-04]action.txt >> U1~73/action.txt
else
 echo -e "[U-04] 쉐도우 패스워드를 사용하거나, 패스워드를 암호화하여 저장하고 있음 - [양호]" >> U1~73/good/[U-04]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-04]good.txt >> U1~73/inspect.txt
fi

##########[U-05] root 홈, 패스 디렉토리 권한 및 패스 설정##########

echo -e "\n=====================================================================================================================================\n[U-05] root 홈, 패스 디렉토리 권한 및 패스 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-05] root 홈, 패스 디렉토리 권한 및 패스 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-05] root 홈, 패스 디렉토리 권한 및 패스 설정" >> U1~73/action.txt


path1=$(echo $PATH | tr -s ':' '\n' | sed -n -e '/^\./p')
#echo로 PATH변수 불러오기 | tr -s명령어로 :문자를 \n으로 변환 | .으로 시작하는 행 출력
path2=$(echo $PATH | grep '::')
#echo로 PATH변수 불러오기 | :: 포함여부 확인

echo -e "[PATH변수]\n$PATH" >> U1~73/log/[U-05]log.txt
cat U1~73/log/[U-05]log.txt >> U1~73/log.txt

if [[ -z $path1 ]] && [[ -z $path2 ]] ; then		#-z는 문자열이 0인 경우
 echo -e "[U-05] PATH 환경변수에 \".\" or \"::\"이 맨 앞이나 중간에 포함되어 있지 않습니다. - [양호]" >> U1~73/good/[U-05]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-05]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-05] PATH 환경변수에 \".\" or \"::\"이 맨 앞이나 중간에 포함되어 있습니다. - [취약]" >> U1~73/bad/[U-05]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-05]bad.txt >> U1~73/inspect.txt

 echo -e "[U-05] root 계정의 설정파일을 들어가서 PATH 변수 앞에 \".\"이나 \":\"이 맨 앞에 존재하지 않도록 변경" >> U1~73/action/[U-05]action.txt
 sed -e 's/\[U-05\] /\n\[조치사항\]\n/g' U1~73/action/[U-05]action.txt >> U1~73/action.txt
fi


##########[U-06]파일 및 디렉토리 소유자 설정##########

echo -e "\n=====================================================================================================================================\n[U-06] 파일 및 디렉토리 소유자 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-06] 파일 및 디렉토리 소유자 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-06] 파일 및 디렉토리 소유자 설정" >> U1~73/action.txt

NO=$(find / -nouser -o -nogroup -print 2>/dev/null) 
log=$(find / -nouser -o -nogroup -print 2>/dev/null | tr -s ' ' '\n')

echo -e "[소유자 및 그룹이 존재하지 않는 파일 및 디렉토리]\n$log" >> U1~73/log/[U-06]log.txt
cat U1~73/log/[U-06]log.txt >> U1~73/log.txt


if [[ -z $NO ]]; then
 echo -e "\n[U-06] 소유자가 존재하지 않는 파일 및 디렉토리가 존재하지 않음 - [양호]" >> U1~73/good/[U-06]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-06]good.txt >> U1~73/inspect.txt
else
 echo -e "\n[U-06] 소유자가 존재하지 않는 파일 및 디렉토리가 존재 - [취약]" >> U1~73/bad/[U-06]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-06]bad.txt >> U1~73/inspect.txt

 echo -e "[U-06] 소유자가 존재하지 않는 파일 및 디렉토리 삭제 또는 소유자 변경 \n rm 명령어를 사용해 파일 및 디렉토리 삭제 \n chown 명령어를 사용해 소유자 및 그룹 변경" >> U1~73/action/[U-06]action.txt
 sed -e 's/\[U-06\] /\n\[조치사항\]\n/g' U1~73/action/[U-06]action.txt >> U1~73/action.txt
fi

##########[U-07] /etc/passwd 파일 소유자 및 권한 설정##########


echo -e "\n=====================================================================================================================================\n[U-07] /etc/passwd 파일 소유자 및 권한 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-07] /etc/passwd 파일 소유자 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-07] /etc/passwd 파일 소유자 및 권한 설정" >> U1~73/action.txt


CF=/etc/passwd  
OWNER=$(ls -l /etc/passwd | awk '{print $3}')
PERM=$(stat /etc/passwd | sed -n '4p' | awk '{print$2}' | cut -c 3-5) 

echo -e "[파일의 소유자 및 권한]\n/etc/passwd 파일의 소유자 : $OWNER 권한 : $PERM" >> U1~73/log/[U-07]log.txt
cat U1~73/log/[U-07]log.txt >> U1~73/log.txt


if [ -f $CF ] ; then
 if [[ $OWNER = 'root' ]] && [[ $PERM -le 644 ]] ; then
  echo -e "[U-07] 파일의 소유자가 root이고, 권한이 644 이하입니다. - [양호]" >> U1~73/good/[U-07]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-07]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-07] 파일의 소유자가 root가 아니거나, 권한이 644 이하가 아닙니다. - [취약]" >> U1~73/bad/[U-07]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-07]bad.txt >> U1~73/inspect.txt

  echo -e "[U-07] /etc/passwd 파일의 소유자 및 권한 변경\n파일 소유자 변경 -> #chown root /etc/passwd\n파일 권한 변경 -> #chmod 644 /etc/passwd" >> U1~73/action/[U-07]action.txt
  sed -e 's/\[U-07\] /\n\[조치사항\]\n/g' U1~73/action/[U-07]action.txt >> U1~73/action.txt
 fi
else
 echo -e "/etc/passwd 파일이 존재하지 않습니다. - [점검]" >> U1~73/bad/[U-07]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-07]bad.txt >> U1~73/inspect.txt

 echo -e "[U-07] /etc/passwd 파일이 존재하지 않으니 점검 필요" >> U1~73/action/[U-07]action.txt
 sed -e 's/\[U-07\] /\n\[조치사항\]\n/g' U1~73/action/[U-07]action.txt >> U1~73/action.txt
fi

##########[U-08] /etc/shadow 파일 소유자 및 권한 설정##########

echo -e "\n=====================================================================================================================================\n[U-08] /etc/shadow 파일 소유자 및 권한 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-08] /etc/shadow 파일 소유자 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-08] /etc/shadow 파일 소유자 및 권한 설정" >> U1~73/action.txt


CF=/etc/shadow  
OWNER=$(ls -l /etc/shadow | awk '{print $3}')
PERM=$(stat /etc/shadow | sed -n '4p' | awk '{print$2}' | cut -c 3-5) 

echo -e "[파일의 소유자 및 권한]\n/etc/shadow 파일의 소유자 : $OWNER 권한 : $PERM" >> U1~73/log/[U-08]log.txt
cat U1~73/log/[U-08]log.txt >> U1~73/log.txt


if [ -f $CF ] ; then
 if [[ $OWNER = 'root' ]] && [[ $PERM -le 400 ]] ; then
  echo -e "[U-08] 파일의 소유자가 root이고, 권한이 400 이하입니다. - [양호]" >> U1~73/good/[U-08]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-08]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-08] 파일의 소유자가 root가 아니거나, 권한이 400 이하가 아닙니다. - [취약]" >> U1~73/bad/[U-08]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-08]bad.txt >> U1~73/inspect.txt

  echo -e "[U-08] /etc/shadow 파일의 소유자 및 권한 변경\n파일 소유자 변경 -> #chown root /etc/shadow\n파일 권한 변경 -> #chmod 644 /etc/shadow" >> U1~73/action/[U-08]action.txt
  sed -e 's/\[U-08\] /\n\[조치사항\]\n/g' U1~73/action/[U-08]action.txt >> U1~73/action.txt
 fi
else
 echo -e "/etc/shadow 파일이 존재하지 않습니다. - [점검]" >> U1~73/bad/[U-08]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-08]bad.txt >> U1~73/inspect.txt

 echo -e "[U-08] /etc/shadow 파일이 존재하지 않으니 점검 필요" >> U1~73/action/[U-08]action.txt
 sed -e 's/\[U-08\] /\n\[조치사항\]\n/g' U1~73/action/[U-08]action.txt >> U1~73/action.txt
fi

##########[U-09] /etc/hosts 파일 소유자 및 권한 설정##########

echo -e "\n=====================================================================================================================================\n[U-09] /etc/hosts 파일 소유자 및 권한 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-09] /etc/hosts 파일 소유자 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-09] /etc/hosts 파일 소유자 및 권한 설정" >> U1~73/action.txt


CF=/etc/hosts  
OWNER=$(ls -l /etc/hosts | awk '{print $3}')
PERM=$(stat /etc/hosts | sed -n '4p' | awk '{print$2}' | cut -c 3-5) 

echo -e "[파일의 소유자 및 권한]\n/etc/hosts 파일의 소유자 : $OWNER 권한 : $PERM" >> U1~73/log/[U-09]log.txt
cat U1~73/log/[U-09]log.txt >> U1~73/log.txt


if [ -f $CF ] ; then
 if [[ $OWNER = 'root' ]] && [[ $PERM -le 600 ]] ; then
  echo -e "[U-09] 파일의 소유자가 root이고, 권한이 600 이하입니다. - [양호]" >> U1~73/good/[U-09]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-09]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-09] 파일의 소유자가 root가 아니거나, 권한이 600 이하가 아닙니다. - [취약]" >> U1~73/bad/[U-09]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-09]bad.txt >> U1~73/inspect.txt

  echo -e "[U-09] /etc/hosts 파일의 소유자 및 권한 변경\n파일 소유자 변경 -> #chown root /etc/hosts\n파일 권한 변경 -> #chmod 644 /etc/hosts" >> U1~73/action/[U-09]action.txt
  sed -e 's/\[U-09\] /\n\[조치사항\]\n/g' U1~73/action/[U-09]action.txt >> U1~73/action.txt
 fi
else
 echo -e "/etc/hosts 파일이 존재하지 않습니다. - [점검]" >> U1~73/bad/[U-09]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-09]bad.txt >> U1~73/inspect.txt

 echo -e "[U-09] /etc/hosts 파일이 존재하지 않으니 점검 필요" >> U1~73/action/[U-09]action.txt
 sed -e 's/\[U-09\] /\n\[조치사항\]\n/g' U1~73/action/[U-09]action.txt >> U1~73/action.txt
fi


##########[U-10]/etc/xinetd.conf 파일 소유자 및 권한 설정##########


echo -e "\n=====================================================================================================================================\n[U-10] /etc/xinetd.conf 파일 소유자 및 권한 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-10] /etc/xinetd.conf 파일 소유자 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-10] /etc/xinetd.conf 파일 소유자 및 권한 설정" >> U1~73/action.txt

CF=/etc/xinetd.conf
PERM=$(stat $CF | sed -n '4p' | awk '{print$2}' | cut -c 3-5)
OWNER=$(ls -l $CF | awk '{print $3}')

echo -e "[/etc/xinetd.conf 파일의 소유자 및 권한]\n소유자:$OWNER , 권한:$PERM" >> U1~73/log/[U-10]log.txt
cat U1~73/log/[U-10]log.txt >> U1~73/log.txt


if [[ $PERM == 600 ]] && [[ $OWNER == 'root' ]]; then
 echo -e "\n[U-10] xinetd.conf 파일의 소유자가 root이고, 권한이 600으로 설정되어 있음 - [양호]" >> U1~73/good/[U-10]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-10]good.txt >> U1~73/inspect.txt
else
 echo -e "\n[U-10] xinetd.conf 파일의 소유자가 root가 아니거나, 권한이 600으로 설정되어있지 않음 - [취약]" >> U1~73/bad/[U-10]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-10]bad.txt >> U1~73/inspect.txt

 echo -e "[U-10] chown, chmod 명령어를 사용하여 /etc/xinetd.conf 파일의 소유자 및 권한 변경 (소유자 root, 권한 600)" >> U1~73/action/[U-10]action.txt
 sed -e 's/\[U-10\] /\n\[조치사항\]\n/g' U1~73/action/[U-10]action.txt >> U1~73/action.txt
fi

##########[U-11] /etc/syslog.conf 파일 소유자 및 권한 설정##########

echo -e "=====================================================================================================================================\n[U-11] /etc/syslog.conf 파일 소유자 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-11] /etc/syslog.conf 파일 소유자 및 권한 설정" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-11] /etc/syslog.conf 파일 소유자 및 권한 설정\n" >> U1~73/log.txt

CF=/etc/syslog.conf  
OWNER=$(ls -l /etc/syslog.conf | awk '{print $3}')
PERM=$(stat /etc/syslog.conf | sed -n '4p' | awk '{print$2}' | cut -c 3-5)  

echo -e "[파일의 소유자 및 권한]\n/etc/syslog.conf 파일의 소유자 : $OWNER 권한 : $PERM" >> U1~73/log/[U-11]log.txt
cat U1~73/log/[U-11]log.txt >> U1~73/log.txt

if [[ -f $CF ]]; then
 if [[ $OWNER = 'root' ]] || [[ $OWNER = 'bin' ]] || [[ $OWNER = 'sys' ]] && [[ $PERM -le 644 ]]; then
  echo -e "[U-11] 파일의 소유자가 root또는 bin또는 sys이고, 권한이 644 이하입니다. - [양호]" >> U1~73/good/[U-11]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-11]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-11] 파일의 소유자가 root또는 bin또는 sys가 아니고, 권한이 644이하가 아닙니다. - [취약]" >> U1~73/bad/[U-11]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-11]bad.txt >> U1~73/inspect.txt

   echo -e "[U-11] /etc/syslog.conf 파일의 소유자 및 권한 변경\n파일 소유자 변경 -> #chown root /etc/syslog.conf 또는 chown bin /etc/syslog.conf 또는 chown sys /etc/syslog.conf\n파일 권한 변경 -> #chmod 644 /etc/syslog.conf" >> U1~73/action/[U-11]action.txt
  sed -e 's/\[U-11\] /\n\[조치사항\]\n/g' U1~73/action/[U-11]action.txt >> U1~73/action.txt
 fi
else
 echo -e "[U-11] /etc/syslog.conf 파일이 존재하지 않습니다. - [점검]" >> U1~73/bad/[U-11]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-11]bad.txt >> U1~73/inspect.txt
fi


##########[U-12] /etc/services 파일 소유자 및 권한 설정##########

echo -e "=====================================================================================================================================\n[U-12] /etc/services 파일 소유자 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-12] /etc/services 파일 소유자 및 권한 설정" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-12] /etc/services 파일 소유자 및 권한 설정\n" >> U1~73/log.txt

CF=/etc/services  
OWNER=$(ls -l /etc/services | awk '{print $3}')
PERM=$(stat /etc/services | sed -n '4p' | awk '{print$2}' | cut -c 3-5)  

echo -e "[파일의 소유자 및 권한]\n/etc/services 파일의 소유자 : $OWNER 권한 : $PERM" >> U1~73/log/[U-12]log.txt
cat U1~73/log/[U-12]log.txt >> U1~73/log.txt

if [[ -f $CF ]]; then
 if [[ $OWNER = 'root' ]] || [[ $OWNER = 'bin' ]] || [[ $OWNER = 'sys' ]] && [[ $PERM -le 644 ]]; then
  echo -e "[U-12] 파일의 소유자가 root또는 bin또는 sys이고, 권한이 644 이하입니다. - [양호]" >> U1~73/good/[U-12]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-12]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-12] 파일의 소유자가 root또는 bin또는 sys가 아니고, 권한이 644이하가 아닙니다. - [취약]" >> U1~73/bad/[U-12]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-12]bad.txt >> U1~73/inspect.txt

   echo -e "[U-12] /etc/services 파일의 소유자 및 권한 변경\n파일 소유자 변경 -> #chown root /etc/services 또는 chown bin /etc/services 또는 chown sys /etc/services\n파일 권한 변경 -> #chmod 644 /etc/services" >> U1~73/action/[U-12]action.txt
  sed -e 's/\[U-12\] /\n\[조치사항\]\n/g' U1~73/action/[U-12]action.txt >> U1~73/action.txt
 fi
else
 echo -e "[U-12] /etc/services 파일이 존재하지 않습니다. - [점검]" >> U1~73/bad/[U-12]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-12]bad.txt >> U1~73/inspect.txt
fi

##########[U-13] SUID, SGID, Sticky bit 관련 설정 및 권한 설정##########

echo -e "\n=====================================================================================================================================\n[U-13] SUID, SGID, Sticky bit 관련 설정 및 권한 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-13] SUID, SGID, Sticky bit 관련 설정 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-13] SUID, SGID, Sticky bit 관련 설정 및 권한 설정" >> U1~73/action.txt

find=$(find / -type f -user root \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \; 2>/dev/null | awk '{print ($1,$9)}')

echo -e "[SUID, SGID 설정 부여되어 있는 파일]\n$find" >> U1~73/log/[U-13]log.txt
cat U1~73/log/[U-13]log.txt >> U1~73/log.txt

if [[ -z $find ]]; then
 echo -e "\n[U-13] 주요 실행파일의 권한에 SUID와 SGID에 대한설정이 부여되어 있지 않음 - [양호]" >> U1~73/good/[U-13]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-13]good.txt >> U1~73/inspect.txt
else
 echo -e "\n[U-13] 주요 실행 파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있음 - [취약]" >> U1~73/bad/[U-13]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-13]bad.txt >> U1~73/inspect.txt

 echo -e "[U-13] 1. 주요 실행파일에 대한 SUID/SGID 설정 여부 확인\n2. 애플리케이션에서 생성한 파일이나, 사용자가 임의로 생성한 파일 등 의심스럽거나 특이한 파일의 발견 시 SUID 제거 필요" >> U1~73/action/[U-13]action.txt
 sed -e 's/\[U-13\] /\n\[조치사항\]\n/g' U1~73/action/[U-13]action.txt >> U1~73/action.txt
fi

##########[U-14] /etc/hosts 파일 소유자 및 권한 설정##########

echo -e "\n=====================================================================================================================================\n[U-14] /etc/hosts 파일 소유자 및 권한 설정\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-14] /etc/hosts 파일 소유자 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-14] /etc/hosts 파일 소유자 및 권한 설정" >> U1~73/action.txt


PERM=$(find / -perm -o+w -type f \( -name "*.profile" -o -name "*.kshrc" -o -name "*.cshrc" -o -name "*.bashrc" -o -name "*.bash_profile" -o -name "*.login" -o -name "*.exrc" -o -name "*.netrc" \) -exec ls -al {} \; | awk '{print $1,$3,$9}')
OWNER=$(find / ! -user root -type f \( -name "*.profile" -o -name "*.kshrc" -o -name "*.cshrc" -o -name "*.bashrc" -o -name "*.bash_profile" -o -name "*.login" -o -name "*.exrc" -o -name "*.netrc" \) -exec ls -al {} \; | awk '{print $1,$3,$9}')

echo -e "[홈 디렉토리 환경변수 파일의 소유자가 root가 아닌 파일]\n$OWNER\n\n[홈 디렉토리 환경변수 파일에 others에게 쓰기 권한이 부여 된 파일]\n$PERM" >> U1~73/log/[U-14]log.txt
cat U1~73/log/[U-14]log.txt >> U1~73/log.txt

 if [[ -z $OWNER ]] && [[ -z $PERM ]] ; then
  echo -e "[U-14] 홈 디렉토리 환경변수 파일 소유자가 root로 지정되어 있고, 홈 디렉토리 환경변수 파일에 others에게 쓰기 권한이 부여되어 있지 않음. - [양호]" >> U1~73/good/[U-14]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-14]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-14] 홈 디렉토리 환경변수 파일 소유자가 root로 지정되어 있지 않거나, 홈 디렉토리 환경변수 파일에 others에게 쓰기 권한이 부여되어 있음. - [취약]" >> U1~73/bad/[U-14]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-14]bad.txt >> U1~73/inspect.txt

  echo -e "[U-14] 환경변수 파일의 소유자를 root 또는 파일 소유자로 지정 및 환경변수 파일의 권한 중 others 쓰기 권한 제거\n파일 소유자 변경 -> #chown <user_name> <file_name>\n파일 권한 변경 -> #chmod o-w <file_name>" >> U1~73/action/[U-14]action.txt
  sed -e 's/\[U-14\] /\n\[조치사항\]\n/g' U1~73/action/[U-14]action.txt >> U1~73/action.txt
 fi

##########[U-15] world writable 파일 점검##########

echo -e "\n=====================================================================================================================================\n[U-15] world writable 파일 점검\n" >> U1~73/log.txt
echo -e "=====================================================================================================================================\n[U-15] world writable 파일 점검\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-15] world writable 파일 점검" >> U1~73/action.txt


PERM=$(find / -perm -o+w -type f -exec ls -al {} \; 2>/dev/null | awk '{print $1,$3,$9}')

echo -e "[world writable 파일]\n$PERM" >> U1~73/log/[U-15]log.txt
cat U1~73/log/[U-15]log.txt >> U1~73/log.txt

 if [[ -z $PERM ]] ; then
  echo -e "[U-15] world writable 파일이 존재하지 않음. - [양호]" >> U1~73/good/[U-15]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-15]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-15] world writable 파일이 존재. - [취약]" >> U1~73/bad/[U-15]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-15]bad.txt >> U1~73/inspect.txt

  echo -e "[U-15] world writable 파일 권한 변경 또는 삭제\n파일 권한 변경 -> #chmod o-w <file_name>\n파일 삭제 -> #rm -rf <파일명>" >> U1~73/action/[U-15]action.txt
  sed -e 's/\[U-15\] /\n\[조치사항\]\n/g' U1~73/action/[U-15]action.txt >> U1~73/action.txt
 fi

##########[U-16] /dev에 존재하지 않는 device 파일 점검##########

echo -e "=====================================================================================================================================\n[U-16] /dev에 존재하지 않는 device 파일 점검\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-16] /dev에 존재하지 않는 device 파일 점검" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-16] /dev에 존재하지 않는 device 파일 점검" >> U1~73/log.txt

DEV=$(find /dev -type f -exec ls -l {} \; 2>/dev/null)

echo -e "\n[dev에 존재하지 않는 파일]\n$DEV" >> U1~73/log/[U-16]log.txt
cat U1~73/log/[U-16]log.txt >> U1~73/log.txt


if [[ -e $DEV ]] ; then
 echo -e "[U-16] /dev에 존재하지 않는 device파일이 존재합니다. - [취약]" >> U1~73/bad/[U-16]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-16]bad.txt >> U1~73/inspect.txt

 echo -e "[U-16] log파일을 보고 major, minor number를 가지지 않는 device파일을 찾아 제거하시오." >> U1~73/action/[U-16]action.txt
 sed -e 's/\[U-16\] /\n\[조치사항\]\n/g' U1~73/action/[U-16]action.txt >> U1~73/action.txt
else
 echo -e "[U-16] /dev에 존재하지 않는 device파일이 존재하지 않습니다. - [양호]" >> U1~73/good/[U-16]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-16]good.txt >> U1~73/inspect.txt
fi

##########[U-17] $HOME/.rhosts, hosts.equiv 사용 금지##########

echo -e "=====================================================================================================================================\n[U-17] $HOME/.rhosts, hosts.equiv 사용 금지\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-17] $HOME/.rhosts, hosts.equiv 사용 금지" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-17] $HOME/.rhosts, hosts.equiv 사용 금지\n" >> U1~73/log.txt

CF=/etc/hosts.equiv
CF2=$HOME/.rhosts

OWNER=$(ls -l /etc/hosts.equiv 2>/dev/null | awk '{print $3}')
OWNER2=$(ls -l $HOME/.rhosts 2>/dev/null | awk '{print $3}')
PERM=$(stat /etc/hosts.equiv 2>/dev/null | sed -n '4p' | awk '{print$2}' | cut -c 3-5)
PERM2=$(stat $HOME/.rhosts 2>/dev/null | sed -n '4p' | awk '{print$2}' | cut -c 3-5)
PLUS=$(cat /etc/hosts.equiv 2>/dev/null | grep '\+')
PLUS2=$(cat $HOME/.rhosts 2>/dev/null | grep '\+')

echo -e "[/etc/hosts.equiv 파일]\n소유자 : $OWNER, 권한 : $PERM, + 설정 존재 여부 : $PLUS\n[\$HOME/.rhosts 파일]\n소유자 : $OWNER2, 권한 : $PERM2, +설정 존재 여부 : $PLUS2" >> U1~73/log/[U-17]log.txt
cat U1~73/log/[U-17]log.txt >> U1~73/log.txt


if [ -e $CF ] ; then		# /etc/hosts.equiv 파일이 존재
 if [[ $OWNER = 'root' ]] && [[ $PERM -le 600 ]] && [[ -z $PLUS ]]; then
  echo -e "[U-17] /etc/hosts.equiv 파일의 설정이 다음과 같습니다. 소유자가 'root', 권한이 600이하, 파일에서 "+" 설정이  존재하지 않음. - [양호]" >> U1~73/good/[U-17]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-17]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-17] /etc/hosts.equiv 파일의 설정이 다음과 같지 않습니다. 소유자가 'root', 권한이 600이하, 파일에서 "+" 설정이  존재하지 않음. - [취약]" >> U1~73/bad/[U-17]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-17]bad.txt >> U1~73/inspect.txt

 echo -e "\n[U-17] [/etc/hosts.equiv 파일 소유자 변경 -> chown root /etc/hosts.equiv\n/etc/hosts.equiv 파일 권한 변경 -> chmod 600 /etc/hosts.equiv\nvi 편집기를 이용하여 \$HOME/.rhosts 파일에서 + 설정 제거 \n vi $HOME/.rhosts \n +를 제거하고 반드시 필요한 호스트 및 계정만 등록" >> U1~73/action/[U-17]action.txt
  sed -e 's/\[U-17\] /\n\[조치사항\]\n/g' U1~73/action/[U-17]action.txt >> U1~73/action.txt
 fi
else
 echo -e "[U-17] /etc/hosts.equiv 파일이 존재하지 않습니다. - [양호]" >> U1~73/good/[U-17]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-17]good.txt >> U1~73/inspect.txt
fi


if [ -e $CF2 ] ; then		# \$HOME/.rhosts 파일이 존재"
 if [[ $OWNER2 = 'root' ]] && [[ $PERM2 -le 600 ]] && [[ -z $PLUS2 ]] ; then
  echo -e "[U-17] \$HOME/.rhosts 파일의 설정이 다음과 같습니다. 소유자가 'root', 권한이 600이하, 파일에서 "+" 설정이  존재하지 않음. - [양호]" >> U1~73/good/[U-17]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-17]good.txt | tail -1  >> U1~73/inspect.txt
 else
  echo -e "[U-17] \$HOME/.rhosts 파일의 설정이 다음과 같지 않습니다. 소유자가 'root', 권한이 600이하, 파일에서 "+" 설정이  존재하지 않음. - [취약]" >> U1~73/bad/[U-17]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-17]bad.txt | tail -1  >> U1~73/inspect.txt

  echo -e "[U-17] \$HOME/.rhosts 파일 소유자 변경 -> chown root \$HOME/.rhosts\n\$HOME/.rhosts 파일 권한 변경 -> chmod 600 \$HOME/.rhosts\nvi 편집기를 이용하여 \$HOME/.rhosts 파일에서 + 설정 제거 \n vi $HOME/.rhosts \n +를 제거하고 반드시 필요한 호스트 및 계정만 등록" >> U1~73/action/[U-17]action.txt
  sed -e 's/\[U-17\] /\n\[조치사항\]\n/g' U1~73/action/[U-17]action.txt >> U1~73/action.txt
 fi
else
 echo -e "[U-17] \$HOME/.rhosts 파일이 존재하지 않습니다. - [양호]" >> U1~73/good/[U-17]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-17]good.txt | tail -1 >> U1~73/inspect.txt
fi

##########[U-18] 접속 IP 및 포트 제한##########

echo -e "=====================================================================================================================================\n[U-18] 접속 IP 및 포트 제한\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-18] 접속 IP 및 포트 제한" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-18] 접속 IP 및 포트 제한" >> U1~73/log.txt

CF=/etc/hosts.deny
CF2=/etc/hosts.allow

DENY=$(sed '/^#/d' $CF | grep 'ALL\:ALL')
ALLOW=$(sed '/^#/d' $CF2 | sed 's/[^0-9]//g')

echo -e "[DENY 여부(빈칸이면 설정 X)] : $DENY \n 허용 IP : $ALLOW" >> U1~73/log/[U-18]log.txt
cat U1~73/log/[U-18]log.txt >> U1~73/log.txt

if [[ -n $DENY ]] && [[ -n $ALLOW ]] ; then
 echo -e "[U-18] /etc/hosts.deny파일에 ALL DENY 설정이 되어 있고, 접속을 허용할 특정 호스트에 대한 IP주소 및 포트 제한이 설정되어 있습니다. - [양호]" >> U1~73/good/[U-18]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-18]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-18] /etc/hosts.deny 파일에 ALL DENY 설정되어 있지 않거나, 접속을 허용할 특정 호스트에 대한 IP주소 및 포트 제한이 설정되어 있지 않습니다. - [취약]" >> U1~73/bad/[U-18]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-18]bad.txt >> U1~73/inspect.txt

 echo -e "[U-18] vi 편집기를 이용해 /etc/hosts.deny 파일에 ALL DENY 설정 후 /etc/hosts.allow 파일에 접속 허용할 IP 및 포트 추가(해당 파일이 없을 경우 생성) " >> U1~73/action/[U-18]action.txt
 sed -e 's/\[U-18\] /\n\[조치사항\]\n/g' U1~73/action/[U-18]action.txt >> U1~73/action.txt
fi

##########[U-19] Finger 서비스 비활성화##########

echo -e "=====================================================================================================================================\n[U-19] Finger 서비스 비활성화\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-19] Finger 서비스 비활성화" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-19] Finger 서비스 비활성화\n" >> U1~73/log.txt


CF=/etc/xinetd.d/finger
FINGER=$(awk '/disable/' $CF)
FINGER_DISABLE=$(awk '/disable/' $CF | grep 'yes')

echo -e "[finger 서비스 비활성화 여부]\n$FINGER" >> U1~73/log/[U-19]log.txt
cat U1~73/log/[U-19]log.txt >> U1~73/log.txt


if [[ -n $FINGER_DISABLE ]] ; then
 echo -e "[U-19] finger 서비스가 비활성화 되어 있음 - [양호]" >> U1~73/good/[U-19]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-19]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-19] finger 서비스가 비활성화 되어 있지 않음 - [취약]" >> U1~73/bad/[U-19]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-19]bad.txt >> U1~73/inspect.txt

 echo -e "[U-19] vi 편집기를 이용하여 /etc/xinetd.d/finger 파일 열고, disable = yes 로 설정\n xinetd 서비스 재시작\n service xinetd restart" >> U1~73/action/[U-19]action.txt
 sed -e 's/\[U-19\] /\n\[조치사항\]\n/g' U1~73/action/[U-19]action.txt >> U1~73/action.txt
fi

##########[U-20] Anonymous FTP 비활성화##########

echo -e "=====================================================================================================================================\n[U-20] Anonymous FTP 비활성화\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-20] Anonymous FTP 비활성화" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-20] Anonymous FTP 비활성화\n" >> U1~73/log.txt

CF=/etc/vsftpd/vsftpd.conf
FTP=$(awk '/anonymous_enable/' $CF)
FTP_ENABLE=$(awk '/anonymous_enable/' $CF | grep 'yes')

echo -e "[anonymous FTP 활성화 여부]\n$FTP" >> U1~73/log/[U-20]log.txt
cat U1~73/log/[U-20]log.txt >> U1~73/log.txt


if [ -n $FTP_ENABLE ]; then
 echo -e "[U-20] Anonymous FTP (익명 ftp) 접속이 차단되어있지 않음 - [취약]" >> U1~73/bad/[U-20]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-20]bad.txt >> U1~73/inspect.txt

 echo -e "[U-20] Anonymous FTP를 사용하지 않는 경우 Anonymous FTP 접속 차단 설정 적용\n vi /etc/vsftpd/vsftpd.conf\n anonymous_enable 을 no로 설정" >> U1~73/action/[U-20]action.txt
 sed -e 's/\[U-20\] /\n\[조치사항\]\n/g' U1~73/action/[U-20]action.txt >> U1~73/action.txt
else
 echo -e "[U-20] Anonymous FTP (익명 ftp) 접속이 차단되어 있음 - [양호]" >> U1~73/good/[U-20]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-20]good.txt >> U1~73/inspect.txt
fi

##########[U-21] r 계열 서비스 비활성화##########

echo -e "=====================================================================================================================================\n[U-21] r 계열 서비스 비활성화\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-21] r 계열 서비스 비활성화" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-21] r 계열 서비스 비활성화\n" >> U1~73/log.txt

rrr=$(ls -alL /etc/xinetd.d/* | egrep "rsh|rlogin|rexec" | egrep -v "grep|klogin|kshell|kexec" | awk '{print $9}')
rsh=$(grep -i 'disable' /etc/xinetd.d/rsh | awk -F= '{print $2}')
rlog=$(grep -i 'disable' /etc/xinetd.d/rlogin | awk -F= '{print $2}')
rex=$(grep -i 'disable' /etc/xinetd.d/rexec | awk -F= '{print $2}')

echo -e "[존재하는 r계열 서비스 파일]\n$rrr" >> U1~73/log/[U-21]log.txt; echo -e "\n[r계열 서비스 비활성화 여부]\nrsh 비활성화 : $rsh\nrlog 비활성화 : $rlog\nrexec비활성화 : $rex" >> U1~73/log/[U-21]log.txt
cat U1~73/log/[U-21]log.txt >> U1~73/log.txt

if [[ -n $rrr ]]; then
 if [[ $rsh =~ "yes" ]] && [[ $rlog =~ "yes" ]] && [[ $rex =~ "yes" ]]; then
  echo -e "[U-21] r 계열 서비스 비활성화 되어 있음 - [양호]" >> U1~73/good/[U-21]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-21]good.txt >> U1~73/inspect.txt
 else 
  echo -e "[U-21] r 계열 서비스 비활성화 되어 있지 않음 - [취약]" >> U1~73/bad/[U-21]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-21]bad.txt >> U1~73/inspect.txt

  echo -e "[U-21] /etc/xinetd.d/ 디렉토리 내 rsh, rlogin, rexec 파일을 열고 Disable = yes 설정" >> U1~73/action/[U-21]action.txt
  sed -e 's/\[U-21\] /\n\[조치사항\]\n/g' U1~73/action/[U-21]action.txt >> U1~73/action.txt
 fi
else
 echo -e "[U-21] r 계열 서비스 활성화 되지 않음 - [양호]" >> U1~73/good/[U-21]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-21]good.txt >> U1~73/inspect.txt
fi

##########[U-22] cron파일 소유자 및 권한 설정##########

echo -e "=====================================================================================================================================\n[U-22] cron파일 소유자 및 권한 설정\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-22] cron파일 소유자 및 권한 설정" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-22] cron파일 소유자 및 권한 설정\n" >> U1~73/log.txt

CF1=/etc/cron.allow
CF2=/etc/cron.deny

OWNER1=$(ls -l /etc | grep 'cron' | grep 'allow' | awk '{print $3}')
OWNER2=$(ls -l /etc | grep 'cron' | grep 'deny' | awk '{print $3}')
PERM1=$(stat /etc/cron.allow 2>/dev/null | sed -n '4p' | awk '{print $2}' | cut -c 3-5)
PERM2=$(stat /etc/cron.deny 2>/dev/null | sed -n '4p' | awk '{print $2}' | cut -c 3-5)

echo -e "[파일의 소유자 및 권한]\n/etc/cron.allow 파일의 소유자 : $OWNER1 권한 : $PERM1 \n/etc/cron.deny 파일의 소유자 : $OWNER2 권한 : $PERM2" >> U1~73/log/[U-22]log.txt
cat U1~73/log/[U-22]log.txt >> U1~73/log.txt


if [[ -f $CF1 ]] ; then
 if [[ $OWNER1 = 'root' ]] && [[ $PERM1 -le 640 ]]; then
  echo -e "[U-22] cron.allow 파일의 소유자가 root이고, 권한이 640 이하입니다. - [양호]" >> U1~73/good/[U-22]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-22]good.txt >> U1~73/inspect.txt
 else
  echo -e "[U-22] cron.allow 파일의 소유자가 root가 아니거나, 권한이 640 이하가 아닙니다. - [취약]" >> U1~73/bad/[U-22]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-22]bad.txt >> U1~73/inspect.txt

   echo -e "[U-22] /etc/cron.allow 파일의 소유자 및 권한 변경\n파일 소유자 변경 -> #chown root /etc/cron.allow\n파일 권한 변경 -> #chmod 640 /etc/cron.allow" >> U1~73/action/[U-22]action.txt
  sed -e 's/\[U-22\] /\n\[조치사항\]\n/g' U1~73/action/[U-22]action.txt >> U1~73/action.txt
 fi
else
 echo -e "[U-22] cron.allow 파일이 존재하지 않습니다. - [점검]" >> U1~73/bad/[U-22]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-22]bad.txt >> U1~73/inspect.txt

 echo -e "[U-22] cron.allow 파일이 존재하지 않으니 점검 필요" >> U1~73/action/[U-22]action.txt
 sed -e 's/\[U-22\] /\n\[조치사항\]\n/g' U1~73/action/[U-22]action.txt >> U1~73/action.txt
fi


if [[ -f $CF2 ]] ; then
 if [[ $OWNER2 = 'root' ]] && [[ $PERM2 -le 640 ]]; then
  echo -e "[U-22] cron.deny 파일의 소유자가 root이고, 권한이 640 이하입니다. - [양호]" >> U1~73/good/[U-22]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-22]good.txt | tail -1 >> U1~73/inspect.txt
 else
  echo -e "[U-22] cron.deny 파일의 소유자가 root가 아니거나, 권한이 640 이하가 아닙니다. - [취약]" >> U1~73/bad/[U-22]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-22]bad.txt | tail -1 >> U1~73/inspect.txt
   echo -e "[U-22] /etc/cron.deny 파일의 소유자 및 권한 변경\n파일 소유자 변경 -> #chown root /etc/cron.deny\n파일 권한 변경 -> #chmod 640 /etc/cron.deny" >> U1~73/action/[U-22]action.txt
  sed -e 's/\[U-22\] /\n\[조치사항\]\n/g' U1~73/action/[U-22]action.txt | tail -3 >> U1~73/action.txt
 fi
else
 echo -e "[U-22] cron.deny 파일이 존재하지 않습니다. - [점검]" >> U1~73/bad/[U-22]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-22]bad.txt | tail -1 >> U1~73/inspect.txt
 echo -e "[U-22] cron.deny 파일이 존재하지 않으니 점검 필요" >> U1~73/action/[U-22]action.txt
 sed -e 's/\[U-22\] /\n\[조치사항\]\n/g' U1~73/action/[U-22]action.txt | tail -1 >> U1~73/action.txt
fi

##########[U-23] Dos 공격에 취약한 서비스 비활성화##########

echo -e "=====================================================================================================================================\n[U-23] Dos 공격에 취약한 서비스 비활성화\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-23] Dos 공격에 취약한 서비스 비활성화" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-23] Dos 공격에 취약한 서비스 비활성화\n" >> U1~73/log.txt

echod=$(grep -i 'disable' /etc/xinetd.d/echo-dgram | awk -F= '{if($2 ~ /yes/) print "yes"}')
echos=$(grep -i 'disable' /etc/xinetd.d/echo-stream | awk -F= '{if($2 ~ /yes/) print "yes"}')
discardd=$(grep -i 'disable' /etc/xinetd.d/discard-dgram | awk -F= '{if($2 ~ /yes/) print "yes"}')
discards=$(grep -i 'disable' /etc/xinetd.d/discard-stream | awk -F= '{if($2 ~ /yes/) print "yes"}')
daytimed=$(grep -i 'disable' /etc/xinetd.d/daytime-dgram | awk -F= '{if($2 ~ /yes/) print "yes"}')
daytimes=$(grep -i 'disable' /etc/xinetd.d/daytime-stream | awk -F= '{if($2 ~ /yes/) print "yes"}')
chargend=$(grep -i 'disable' /etc/xinetd.d/chargen-dgram | awk -F= '{if($2 ~ /yes/) print "yes"}')
chargens=$(grep -i 'disable' /etc/xinetd.d/chargen-stream | awk -F= '{if($2 ~ /yes/) print "yes"}')

echo -e "[echo 서비스 비활성화 여부]\n echo-dgram disable : $echod\n echo-stram disable : $echos\n\n[discard 서비스 비활성화 여부]\n discard-dgram disable : $discardd\n discard-stram disable : $discards\n\n[daytime 서비스 비활성화 여부]\n daytime-dgram disable : $daytimed\n daytime-stram disable : $daytimes\n\n[chargen 서비스 비활성화 여부]\n chargen-dgram disable : $chargend\n chargen-stram disable : $chargens" >> U1~73/log/[U-23]log.txt
cat U1~73/log/[U-23]log.txt >> U1~73/log.txt

 if [[ $echod == "yes" ]] && [[ $echos == "yes" ]] && [[ $discardd == "yes" ]] && [[ $discards == "yes" ]] &&[[ $daytimed == "yes" ]] && [[ $daytimes == "yes" ]] && [[ $chargend == "yes" ]] && [[ $chargens == "yes" ]] ; then
  echo -e "[U-23] 사용하지 않는 DoS 공격에 취약한 서비스가 비활성화 되어 있음 - [양호]" >> U1~73/good/[U-23]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-21]good.txt >> U1~73/inspect.txt
 else 
  echo -e "[U-23] 사용하지 않는 DoS 공격에 취약한 서비스 비활성화 되어 있지 않음 - [취약]" >> U1~73/bad/[U-23]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-21]bad.txt >> U1~73/inspect.txt
  echo -e "[U-23] vi 편집기를 이용해 "/etc/xinetd.d/" 디렉토리 내 echo, discard, daytime, chargen의 -dgram, stream 파일에 들어가 disable = yes 설정" >> U1~73/action/[U-21]action.txt
  sed -e 's/\[U-23\] /\n\[조치사항\]\n/g' U1~73/action/[U-23]action.txt >> U1~73/action.txt
 fi


##########[U-24] NFS 서비스 비활성화##########

echo -e "=====================================================================================================================================\n[U-24] NFS 서비스 비활성화\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-24] NFS 서비스 비활성화" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-24] NFS 서비스 비활성화\n" >> U1~73/log.txt

nfs=$(systemctl status nfs | grep 'Active' | awk '{print $3}' | sed 's/[^a-z,A-Z]//g')

echo -e "[U-24] [nfs 서비스 활성화 여부] : $nfs" >> U1~73/log/[U-24]log.txt
cat U1~73/log/[U-24]log.txt >> U1~73/log.txt

if [[ $nfs =~ "dead" ]] ; then
 echo -e "[U-24] NFS 서비스 비활성화 되어 있음 - [양호]" >> U1~73/good/[U-24]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-24]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-24] NFS 서비스 비활성화 되어 있지 않음 - [취약]" >> U1~73/bad/[U-24]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-24]bad.txt >> U1~73/inspect.txt

 echo -e "[U-24] /etc/dfs/dfstab의 모든 공유 제거\nkill -9 명령어로 NFS 데몬(nfsd, statd, mountd, lockd) 중지\nrm 명령어로 시동 스크립트 삭제 또는 mv 명령어로 스크립트 이름 변경" >> U1~73/action/[U-24]action.txt
 sed -e 's/\[U-24\] /\n\[조치사항\]\n/g' U1~73/action/[U-24]action.txt >> U1~73/action.txt
fi


##########[U-26] automountd 제거##########

echo -e "=====================================================================================================================================\n[U-26] automountd 제거\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-26] automountd 제거" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-26] automountd 제거\n" >> U1~73/log.txt

autofs=$(systemctl status autofs | sed -n '3p' | awk '{print $3}' | sed 's/[^a-z,A-Z]//g')

echo -e "[automountd 서비스 활성화 여부] : $autofs" >> U1~73/log/[U-26]log.txt
cat U1~73/log/[U-26]log.txt >> U1~73/log.txt

if [[ $autofs =~ "dead" ]] ; then
 echo -e "[U-26] automountd 서비스 비활성화 되어 있음 - [양호]" >> U1~73/good/[U-26]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-26]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-26] automountd 서비스 비활성화 되어 있지 않음 - [취약]" >> U1~73/bad/[U-26]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-26]bad.txt >> U1~73/inspect.txt

 echo -e "[U-26] kill -9 [PID] 명령어로 automountd 데몬 중지\nrm 명령어로 시동 스크립트 삭제 또는 mv 명령어로 스크립트 이름 변경\n1.위치 확인 : #ls -al /etc/rc.d/rc*.d/* | grep automount (or autofs)\n2. 이름 변경 : #mv /etc/rc.d/rc2.d/S28automountd /etc/rc.d/rc2.d/_S28automountd" >> U1~73/action/[U-26]action.txt
 sed -e 's/\[U-26\] /\n\[조치사항\]\n/g' U1~73/action/[U-26]action.txt >> U1~73/action.txt
fi


##########[U-27]RPC 서비스 확인##########

echo -e "=====================================================================================================================================\n[U-27]RPC 서비스 확인\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-27]RPC 서비스 확인" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-27]RPC 서비스 확인\n" >> U1~73/log.txt

rpc_cmsd=$(grep -i 'disable' /etc/xinetd.d/rpc.cmsd | awk -F= '{if($2 ~ /yes/) print "yes"}')
rpc_ttdbserverd=$(grep -i 'disable' /etc/xinetd.d/rpc.ttdbserverd | awk -F= '{if($2 ~ /yes/) print "yes"}')
rpc_nisd=$(grep -i 'disable' /etc/xinetd.d/rpc.nisd | awk -F= '{if($2 ~ /yes/) print "yes"}')
rpc_pcnfsd=$(grep -i 'disable' /etc/xinetd.d/rpc.pcnfsd | awk -F= '{if($2 ~ /yes/) print "yes"}')
rpc_statd=$(grep -i 'disable' /etc/xinetd.d/rpc.statd | awk -F= '{if($2 ~ /yes/) print "yes"}')
rpc_rquotad=$(grep -i 'disable' /etc/xinetd.d/rpc.rquotad | awk -F= '{if($2 ~ /yes/) print "yes"}')
sadmind=$(grep -i 'disable' /etc/xinetd.d/sadmind | awk -F= '{if($2 ~ /yes/) print "yes"}')
ruserd=$(grep -i 'disable' /etc/xinetd.d/ruserd | awk -F= '{if($2 ~ /yes/) print "yes"}')
walld=$(grep -i 'disable' /etc/xinetd.d/walld | awk -F= '{if($2 ~ /yes/) print "yes"}')
sprayd=$(grep -i 'disable' /etc/xinetd.d/sprayd | awk -F= '{if($2 ~ /yes/) print "yes"}')
rstatd=$(grep -i 'disable' /etc/xinetd.d/rstatd | awk -F= '{if($2 ~ /yes/) print "yes"}')
rexd=$(grep -i 'disable' /etc/xinetd.d/rexd | awk -F= '{if($2 ~ /yes/) print "yes"}')
k_server=$(grep -i 'disable' /etc/xinetd.d/kcms_server | awk -F= '{if($2 ~ /yes/) print "yes"}')
cachefsd=$(grep -i 'disable' /etc/xinetd.d/cachefsd | awk -F= '{if($2 ~ /yes/) print "yes"}')

echo -e "[RPC 서비스 비활성화 여부]\n rpc.cmsd disable : $rpc_cmsd\n rpc.ttdbserverd disable : $rpc_ttdbserverd\n rpc.nisd disable : $rpc_nisd\n rpc.pcnfsd disable : $rpc_pcnfsd\n rpc.statd disable : $rpc_statd\n rpc.rquotad disable : $rpc_rquotad\n sadmind disable : $sadmind\n ruserd disable : $ruserd\n walld disable : $walld\n sprayd disable : $sprayd\n rstatd disable : $rstatd\n rexd disable : $rexd\n kcms_server disable : $k_server\n cachefsd disable : $cachefsd" >> U1~73/log/[U-27]log.txt
cat U1~73/log/[U-27]log.txt >> U1~73/log.txt


if [[ $rpc_cmsd =~ "yes" ]] && [[ $rpc_ttdbserverd =~ "yes" ]] && [[ $rpc_nisd =~ "yes" ]] && [[ $rpc_pcnfsd =~ "yes" ]] && [[ $rpc_statd =~ "yes" ]] && [[ $rpc_rquotad =~ "yes" ]] && [[ $sadmind =~ "yes" ]] && [[ $ruserd =~ "yes" ]] && [[ $walld =~ "yes" ]] && [[ $sprayd =~ "yes" ]] && [[ $rstatd =~ "yes" ]] && [[ $rexd =~ "yes" ]] && [[ $k_server =~ "yes" ]] && [[ $cachefsd =~ "yes" ]] ; then
  echo -e "[U-27] 불필요한 RPC 서비스가 비활성화 되어 있음 - [양호]" >> U1~73/good/[U-27]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-27]good.txt >> U1~73/inspect.txt
 else 
  echo -e "[U-27] 불필요한 RPC 서비스가 비활성화 되어 있지 않음 - [취약]" >> U1~73/bad/[U-27]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-27]bad.txt >> U1~73/inspect.txt

  echo -e "[U-27] vi 편집기를 이용해 /etc/xinetd.d/ 디렉토리 내 rpc.cmsd, rpc,ttdbserverd, rpc.nisd, rpc.pcnfsd, rpc.statd, rpc.rquotad, sadmind, ruserd, walld, sprayd, rstatd, rexd, kcms_server, cachefsd 파일에 들어가 disable = yes 설정" >> U1~73/action/[U-27]action.txt
  sed -e 's/\[U-27\] /\n\[조치사항\]\n/g' U1~73/action/[U-27]action.txt >> U1~73/action.txt
 fi


##########[U-28] NIS, NIS+ 점검##########

echo -e "=====================================================================================================================================\n[U-28] automountd 제거\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-28] automountd 제거" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-28] automountd 제거\n" >> U1~73/log.txt

NIS=$(ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.tppasswdd|rpc.tyupdated" | grep -v "grep -E")

echo -e "[활성화 되어 있는 NIS, NIS+ 서비스] : $NIS" >> U1~73/log/[U-28]log.txt
cat U1~73/log/[U-28]log.txt >> U1~73/log.txt

if [[ -z $NIS ]] ; then
 echo -e "[U-28] NIS, NIS+ 서비스 비활성화 되어 있음 - [양호]" >> U1~73/good/[U-28]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-28]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-28] NIS, NIS+ 서비스 비활성화 되어 있지 않음 - [취약]" >> U1~73/bad/[U-28]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-28]bad.txt >> U1~73/inspect.txt

 echo -e "[U-28] kill -9 [PID] 명령어로 NIS, NIS+ 데몬 중지\nrm 명령어로 시동 스크립트 삭제 또는 mv 명령어로 스크립트 이름 변경\n1.위치 확인 : #ls -al /etc/rc.d/rc*.d/* | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated"\n2. 이름 변경 : #mv /etc/rc.d/rc2.d/S73ypbind /etc/rc.d/rc2.d/_S73ypbind" >> U1~73/action/[U-28]action.txt
 sed -e 's/\[U-28\] /\n\[조치사항\]\n/g' U1~73/action/[U-28]action.txt >> U1~73/action.txt
fi

##########[U-29] tftp, talk 서비스 비활성화##########

echo -e "=====================================================================================================================================\n[U-29] tftp, talk 서비스 비활성화\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-29] tftp, talk 서비스 비활성화" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-29] tftp, talk 서비스 비활성화\n" >> U1~73/log.txt

tftp=$(grep -i 'disable' /etc/xinetd.d/tftp | awk -F= '{if($2 ~ /yes/) print "yes"}')
talk=$(grep -i 'disable' /etc/xinetd.d/talk | awk -F= '{if($2 ~ /yes/) print "yes"}')
ntalk=$(grep -i 'disable' /etc/xinetd.d/ntalk | awk -F= '{if($2 ~ /yes/) print "yes"}')

echo -e "[tftp, talk, ntalk 서비스 비활성화 여부]\n tftp disable : $tftp\n talk disable : $talk\n ntalk disable : $ntalk">> U1~73/log/[U-29]log.txt
cat U1~73/log/[U-29]log.txt >> U1~73/log.txt

 if [[ $tftp == "yes" ]] && [[ $talk == "yes" ]] && [[ $ntalk == "yes" ]] ; then
  echo -e "[U-29] tftp, talk, ntalk 서비스가 비활성화 되어 있음 - [양호]" >> U1~73/good/[U-29]good.txt
  awk '{print substr($0,index($0,$2))}' U1~73/good/[U-29]good.txt >> U1~73/inspect.txt
 else 
  echo -e "[U-29] tftp, talk, ntalk 서비스가 비활성화 되어 있지 않음 - [취약]" >> U1~73/bad/[U-29]bad.txt
  awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-29]bad.txt >> U1~73/inspect.txt

  echo -e "[U-29] vi 편집기를 이용해 "/etc/xinetd.d/" 디렉토리 내 tftp, talk, ntalk 파일에 들어가 disable = yes 설정" >> U1~73/action/[U-29]action.txt
  sed -e 's/\[U-29\] /\n\[조치사항\]\n/g' U1~73/action/[U-29]action.txt >> U1~73/action.txt
 fi


##########[U-30] Sendmail 버전 점검##########

echo -e "=====================================================================================================================================\n[U-30] Sendmail 버전 점검\n" >> U1~73/inspect.txt
echo -e "=====================================================================================================================================\n[U-30] Sendmail 버전 점검" >> U1~73/action.txt
echo -e "\n=====================================================================================================================================\n[U-30] Sendmail 버전 점검\n" >> U1~73/log.txt

version=$(sendmail -d0.1 < /dev/null | grep -i 'Version' | awk '{print $2}' | tr -d '.')
new=$(sendmail -d0.1 < /dev/null | grep -i 'Version' | awk '{print $2}' | awk -F. '{if($1<8 || $1=8 && $2>17 || $1=8 && $2=17 && $3<=1) print "good"}')

echo -e "[sendmail 버전]" >> U1~73/log/[U-30]log.txt
sendmail -d0.1 < /dev/null | grep -i 'Version' >> U1~73/log/[U-30]log.txt
echo -e "(23.04.02 기준 최신버전 : 8.17.1 버전)" >> U1~73/log/[U-30]log.txt
cat U1~73/log/[U-30]log.txt >> U1~73/log.txt

if [[ $new == "good" ]] ; then
 echo -e "[U-30] Sendmail 버전이 최신버전입니다. - [양호]" >> U1~73/good/[U-30]good.txt
 awk '{print substr($0,index($0,$2))}' U1~73/good/[U-30]good.txt >> U1~73/inspect.txt
else
 echo -e "[U-30] Sendmail 버전이 최신버전이 아닙니다. - [취약]" >> U1~73/bad/[U-30]bad.txt
 awk '{print substr($0,index($0,$2))}' U1~73/bad/[U-30]bad.txt >> U1~73/inspect.txt

 echo -e "[U-30] Sendmail 서비스 실행 여부 및 버전 점검 후, http://www.sendmail.org/ 또는 각 OS 벤더사의 보안 패치설치" >> U1~73/action/[U-30]action.txt
 sed -e 's/\[U-30\] /\n\[조치사항\]\n/g' U1~73/action/[U-30]action.txt >> U1~73/action.txt
fi
