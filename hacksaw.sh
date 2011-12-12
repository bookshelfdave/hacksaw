#!/bin/sh

# JUST for the demo...
export HACKSAW_HOME=/Users/dparfitt/src/hacksaw
export JAVA_OPTS=-javaagent:${HACKSAW_HOME}/Hacksaw.jar
jruby.sh $1
