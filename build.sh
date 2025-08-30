

set -e




source ./prepareVars.sh


echo "--- 1. Cleaning up previous build artifacts ---"
rm -rf obj bin
mkdir -p  obj bin



echo "--- 2. Compiling Resources ---"
$BUILD_TOOLS/aapt2 compile --dir res -o bin/compiled_res.zip


echo "--- 3. Linking Resources and Generating R.java ---"
$BUILD_TOOLS/aapt2 link \
    -o bin/base.apk \
    --manifest AndroidManifest.xml \
    -I "$PLATFORM/android.jar" \
    --java src \
    bin/compiled_res.zip

echo "--- 4. Compiling Java Sources ---"
javac -d obj \
    -classpath "$PLATFORM/android.jar" \
    src/com/drnull/blindify/*.java


echo "--- 5. Converting .class files to DEX format ---"
$BUILD_TOOLS/d8 obj/com/drnull/blindify/*.class \
    --output bin \
    --lib "$PLATFORM/android.jar"



echo "--- 6. Packaging the APK ---"
# Start with the resource-only APK
cp bin/base.apk bin/unaligned_app.apk
# Add the compiled Java code
zip -uj bin/unaligned_app.apk bin/classes.dex


echo "--- 7. Aligning the APK ---"
$BUILD_TOOLS/zipalign -v 4 bin/unaligned_app.apk bin/Blindify-unsigned.apk

echo "--- 8. Signing the APK ---"

if [ "$1" = "production" ]; then
    echo "Running in PRODUCTION mode."

    PRODUCTION_KEYSTORE_FILE="my-release-key.keystore"
    PRODUCTION_KEYSTORE_ALIAS="my-key-alias"

    if [ ! -f "$PRODUCTION_KEYSTORE_FILE" ]; then
        echo "ERROR: Production keystore not found at '$PRODUCTION_KEYSTORE_FILE'"
        echo "Build failed."
        exit 1
    fi

    echo -n "Enter password for $PRODUCTION_KEYSTORE_FILE: "
    read -s KEYSTORE_PASSWORD
    echo "" 

    echo "Signing APK with production key..."
    $BUILD_TOOLS/apksigner sign \
        --ks "$PRODUCTION_KEYSTORE_FILE" \
        --ks-key-alias "$PRODUCTION_KEYSTORE_ALIAS" \
        --ks-pass "pass:$KEYSTORE_PASSWORD" \
        --out ./releases/Blindify.apk \
        bin/Blindify-unsigned.apk

    if [ $? -eq 0 ]; then
        echo "--- APK signed successfully! ---"
        echo "Signed APK is located at: ./releases/Blindify.apk"
    else
        echo "--- ERROR: APK signing failed! ---"
        exit 1
    fi

else
    echo "Running in DEBUG mode."
    echo "Signing APK with debug key..."
    $BUILD_TOOLS/apksigner sign \
        --ks debug.keystore \
        --ks-pass pass:android \
        --out bin/Blindify-debug.apk \
        bin/Blindify-unsigned.apk

    echo "--- APK signed successfully with debug key! ---"
    echo "Signed APK is located at: bin/Blindify-debug.apk"

fi
