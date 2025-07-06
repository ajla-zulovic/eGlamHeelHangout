# === STRIPE: Zadrži push provisioning klase i povezane unutrašnje klase ===
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity$* { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$* { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider { *; }
-keep class com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener { *; }

# === STRIPE: Dodatni Stripe paketi ako koristiš osnovno plaćanje ===
-keep class com.stripe.android.model.** { *; }
-keep class com.stripe.android.payments.** { *; }
-keep class com.stripe.android.view.** { *; }
-keep class com.stripe.android.Stripe { *; }

# === Ako koristiš ReactNative Stripe bridge (ne smeta ni za Flutter) ===
-keep class com.reactnativestripesdk.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }

# === Sprečava R8 da ukloni sve Activity klase (sigurno) ===
-keep public class * extends android.app.Activity

# === Zadrži anotirane klase (Stripe koristi @Keep) ===
-keep @androidx.annotation.Keep class * { *; }

# === Ako se koristi refleksija (Stripe koristi u pozadini) ===
-keepclassmembers class * {
    public *;
}
