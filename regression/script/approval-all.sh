#!/usr/bin/env bash

for file in $(find regression/fixtures/approvals -ipath "*.received.*"); do
	approved_path=$(echo "$file" | sed 's/received/approved/')
	mv "$file" "$approved_path"
done
