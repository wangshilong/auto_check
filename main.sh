#!/bin/sh
#Written by Wang Shilong <wangsl.fnst@cn.fujitsu.com>

MAIN_URL="https://patchwork.kernel.org/project/linux-nfs/list/"
PATCH_URL="https://patchwork.kernel.org/patch/"
LOG_DIR="/tmp/auto_check"
TIME_OUT=60

rm -rf $LOG_DIR
mkdir -p $LOG_DIR || echo "mkdir $LOG_DIR fails"

wget -O out $MAIN_URL -T $TIME_OUT || exit 1
grep '/patch/' out | awk -F '/' '{print $3}' >patch_index

touch send_index
grep -F -v -f send_index patch_index | uniq -u >out1
rm -f patch_index && mv out1 patch_index
rm -f out || echo "rm out fails"

while read line
do
	wget $PATCH_URL/$line/mbox -O $LOG_DIR/$line -T $TIME_OUT || echo "wget $line fails";
	./checkpatch.pl --no-tree --patch $LOG_DIR/$line || ./checkpatch.pl --no-tree --patch $LOG_DIR/$line >$LOG_DIR/$line""_fail

done < patch_index
ls $LOG_DIR | grep fail | awk -F '_' '{print $1}' > ./check_fail

while read line
do
	#double check whether it is a patch
	#get email from and cc to linux-btrfs
	is_null=`less $LOG_DIR/$line | grep Signed-off-by`
	if [ -z "$is_null" ];then
		continue
	fi
	echo $line >> send_index

	to=`less $LOG_DIR/$line | grep From: | awk -F ':' '{print $2}'`
	Subject=`less $LOG_DIR/$line | grep Subject: | awk -F 'Subject:' '{print $2}' `
	name=`echo $to| awk -F ':' '{print $2}'| awk -F '<' '{print $1}'`
	echo $to
	echo $Subject
	msg=`less $LOG_DIR/$line""_fail`
	echo $msg
	sh ./mail.sh "wangshilong1991@gmail.com" "Re: $Subject" "$msg"
done < ./check_fail
