# awk.sc script
/tom/ { count["tom"]++ }
/mary/ { count["mary"]++ }
END{print "There are " count["tom"] " Toms in the file and
   " count["mary"]" Marys in the file."}
   
