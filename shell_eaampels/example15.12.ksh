filedb=db
if [[ ! -a  $filedb ]]
then
  print "$filedb does not exist"
  exit 1
fi
