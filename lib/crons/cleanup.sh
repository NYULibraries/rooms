#!/bin/sh

root_dir=/apps/room_reservation

# Set environment
environment=production

# Set log file location
log_file=$root_dir/log/cron

. /etc/profile
cd $root_dir
rake --trace --verbose cleanup:expired_users RAILS_ENV=$environment > $log_file 2>&1
if [ $? -ne 0 ]; then
        date >> $log_file
        mail_file=$root_dir/tmp/tmp.letter
        echo "Below are the contents of the log from the failed Room Reservation _expired users_ cleanup:" > $mail_file
        echo "-------------------------------------------------------" >> $mail_file
        cat $log_file >> $mail_file
        /bin/mail -s "Room Reservation cleanup failed" web.services@library.nyu.edu < $mail_file
        cp $log_file $log_file.`date +%Y%m%d%H%M`
fi

rake --trace --verbose cleanup:deleted_reservations RAILS_ENV=$environment > $log_file 2>&1
if [ $? -ne 0 ]; then
        date >> $log_file
        mail_file=$root_dir/tmp/tmp.letter
        echo "Below are the contents of the log from the failed Room Reservation _deleted records_ cleanup:" > $mail_file
        echo "-------------------------------------------------------" >> $mail_file
        cat $log_file >> $mail_file
        /bin/mail -s "Room Reservation cleanup failed" web.services@library.nyu.edu < $mail_file
        cp $log_file $log_file.`date +%Y%m%d%H%M`
fi