clear
mkdir -p bin
crystal build src/logger.cr -o bin/logger

RESULT=$?
if [ $RESULT -eq 0 ]; then
  bin/logger $@
fi
