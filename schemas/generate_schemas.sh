#!/usr/bin/env bash

protoc --swift_out=../beanstorm/schemas beanstorm_schema.proto
protoc --nanopb_out=../beanstorm_os/src/schemas beanstorm_schema.proto

