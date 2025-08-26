

set -e




source ./prepareVar.sh


echo "--- 1. Cleaning up previous build artifacts ---"
rm -rf obj bin build
mkdir -p  obj bin build



echo "--- 2. Compiling Resources ---"
$BUILD_TOOLS/aapt2 compile --dir res -o bin/compiled_res.zip


echo "--- 3. Linking Resources and Generating R.java ---"
$BUILD_TOOLS/aapt2 link \
    -o bin/base.apk \
    --manifest AndroidManifest.xml \
    -I "$PLATFORM/android.jar" \
    -I "assets/material-1.12.0.aar" \
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
$BUILD_TOOLS/apksigner sign \
    --ks debug.keystore \
    --ks-pass pass:android \
    --out bin/Blindify.apk \
    bin/Blindify-unsigned.apk


