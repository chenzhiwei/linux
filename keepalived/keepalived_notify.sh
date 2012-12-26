#!/bin/bash

role=$1   # INSTANCE/GROUP
name=$2   # name of INSTANCE/GROUP
state=$3  # target state of transition(MASTER/BACKUP/FAULT)

echo "role: $role"
echo "name of role: $name"
echo "target state of role name: $state"
