#!/bin/bash

for d in `dirname $0`/../.gen/*/comments.db
do
  echo "In $d:"
  sqlite3 $d "select '  ',images.name,comments.name,comment
              from images,comments
              where img_id=images.id"
done
