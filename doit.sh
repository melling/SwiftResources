#!/bin/sh -x

cp swift_urls.tsv /tmp
bin/gen_go_var.swift
#bin/gen_go_var.swift > db.go
