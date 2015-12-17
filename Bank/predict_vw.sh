#!/bin/bash
echo 'RUNNING TEST ---------------------------'
vw -d ./Processed/data.vw.test.txt -t -i normal.vw -p pred.vw.txt --invert_hash model.vw.txt
