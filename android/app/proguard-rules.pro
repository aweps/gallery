# Flutter Gallery — R8/ProGuard keep rules.
#
# shared_preferences pulls in kotlinx-coroutines, whose generated code references
# an internal coroutines class (kotlin.coroutines.jvm.internal.SpillingKt) that
# isn't on the app classpath. With isMinifyEnabled = true this makes R8 fail the
# release build at :app:minifyReleaseWithR8 ("Missing class ... SpillingKt").
#
# This is the exact rule the Android Gradle Plugin generates in
# build/app/outputs/mapping/release/missing_rules.txt for this build.
-dontwarn kotlin.coroutines.jvm.internal.SpillingKt
