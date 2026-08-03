# linux
cmake .. \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_BINDINGS=ON \
  -DBUILD_TESTING=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DCMAKE_C_FLAGS="-fPIC -Os -ffunction-sections -fdata-sections" \
  -DCMAKE_CXX_FLAGS="-fPIC -Os -ffunction-sections -fdata-sections"

cmake --build . -j$(nproc)

g++ -shared \
  -Wl,--whole-archive \
  bindings/c/libtag_c.a \
  taglib/libtag.a \
  -Wl,--no-whole-archive \
  -lz \
  -o libtag.so

strip --strip-unneeded libtag.so

ls -lh libtag.so

nm -D --defined-only libtag.so | grep tag_

find ~/taglib-2.3.1 -name "tag_c.h"

# android arm64

cmake .. \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_BINDINGS=ON \
  -DBUILD_TESTING=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DCMAKE_C_FLAGS="-fPIC -Os -ffunction-sections -fdata-sections" \
  -DCMAKE_CXX_FLAGS="-fPIC -Os -ffunction-sections -fdata-sections"

cmake --build . -j$(nproc)

#  a+a -> so ပေါင်းတာ
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++ \
  --target=aarch64-linux-android21 \
  -shared \
  -Wl,--whole-archive \
  bindings/c/libtag_c.a \
  taglib/libtag.a \
  -Wl,--no-whole-archive \
  -lz \
  -o libtag.so

# android arm

cmake .. \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=armeabi-v7a \
  -DANDROID_PLATFORM=android-21 \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_BINDINGS=ON \
  -DBUILD_TESTING=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DCMAKE_C_FLAGS="-fPIC -Os -ffunction-sections -fdata-sections" \
  -DCMAKE_CXX_FLAGS="-fPIC -Os -ffunction-sections -fdata-sections"
  
  cmake --build . -j$(nproc)
  
#  a+a -> so ပေါင်းတာ
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++ \
  --target=armv7a-linux-androideabi21 \
  -shared \
  -Wl,--whole-archive \
  bindings/c/libtag_c.a \
  taglib/libtag.a \
  -Wl,--no-whole-archive \
  -lz \
  -o libtag.so
  
# ပြီးရင် size လျှော့ဖို့ Android NDK llvm-strip သုံး
# အတူတူပဲ arm+arm64
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip \
  --strip-unneeded libtag.so
  
# စမ်းသပ်ဖို့ 

ARM64 ဆိုရင်:

ELF 64-bit ... ARM aarch64

ARM32 ဆိုရင်:

ELF 32-bit ... ARM
