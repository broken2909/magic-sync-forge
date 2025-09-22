#!/usr/bin/env sh
APP_HOME=$(cd "$(dirname "$0")" && pwd)
CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"
JAVACMD="${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk}/bin/java"

if [ ! -x "$JAVACMD" ]; then
    JAVACMD=$(which java 2>/dev/null || echo "java")
fi

exec "$JAVACMD" -Xmx256m -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
