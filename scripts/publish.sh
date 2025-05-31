#!/bin/bash
set -e

dart format .
dart pub publish
