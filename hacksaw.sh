#!/bin/sh

# JUST for the demo...
#export HACKSAW_HOME=/Users/dparfitt/src/hacksaw
export JAVA_OPTS=-javaagent:Hacksaw.jar
jruby.sh $1
