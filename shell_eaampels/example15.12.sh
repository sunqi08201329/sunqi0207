filedb=db
if [ ! -f  $filedb ]
then
  echo "$filedb does not exist"
  exit 1
fi
