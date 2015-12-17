#!/bin/bash
echo 'Removing old files'
rm val.vw.txt
rm model.vw.txt
rm Processed/*.txt.cache
echo 'Starting to process'
echo 'vw -d ./Processed/data.vw.train.txt -f normal.vw -c --passes' "$1" "${@:2}"
echo 'RUNNING TRAIN --------------------------' 
vw -d ./Processed/data.vw.train.txt -f normal.vw -c --passes "$1" "${@:2}"
echo 'RUNNING VALIDATION ---------------------------'
vw -d ./Processed/data.vw.val.txt -t -i normal.vw -p val.vw.txt --invert_hash model.vw.txt
