set filedb = db
if ( ! -e  $filedb ) then
  echo "$filedb does not exist"
  exit 1
endif
