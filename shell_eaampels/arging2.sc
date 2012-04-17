BEGIN{FS=":"; name=ARGV[2]
   print "ARGV[2] is " ARGV[2]
   delete ARGV[2]
}
$1  ~ name { print $0 }
