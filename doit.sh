#!/bin/sh -x

cp swift_urls.tsv /tmp
bin/gen_go_var.sh | grep Duplicate
bin/gen_go_var.sh > db.go
