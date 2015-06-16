#!/bin/bash
for f in *.{json,yaml}; do kubectl create -f $f; done
