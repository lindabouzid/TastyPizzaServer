#! /usr/bin/env bash

pkill swift
cd .build/release
./TastyPizzaServer
cd -
