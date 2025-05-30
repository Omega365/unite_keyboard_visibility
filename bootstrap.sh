#!/bin/bash
set -e

fvm use
dart pub get
bash run_pigeon.sh

(
    cd example
    flutter build apk --config-only
)
