#!/bin/sh -x

cp swift_urls.tsv /tmp
bin/gen_go_var.swift | grep Duplicate
bin/gen_go_var.swift > db.go
