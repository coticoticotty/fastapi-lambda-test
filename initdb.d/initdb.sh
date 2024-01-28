#!/bin/bash
set -e

psql -U dev -d db_dev -f /sql_scripts/create_tables.sql
