# Stripe Payment Integration Guide

## Current Status
The discontinued `stripe_payment` package has been removed due to iOS compatibility issues.

## When You're Ready to Add Payment

### Option 1: Use flutter_stripe (Recommended)

1. **Add to pubspec.yaml:**
```yaml
dependencies:
  flutter_stripe: ^10.0.0
```

2. **Install:**
```bash
flutter pub get
cd ios && pod install
```

3. **Setup (iOS) - Add to `ios/Runner/AppDelegate.swift`:**
```swift
import Stripe

// In application didFinishLaunchingWithOptions
StripeAPI.defaultPublishableKey = "pk_test_your_key_here"
```

4. **Setup (Android) - Add to `android/app/src/main/kotlin/.../MainActivity.kt`:**
```kotlin
import com.stripe.android.PaymentConfiguration

override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    PaymentConfiguration.init(applicationContext, "pk_test_your_key_here")
}
```

5. **Usage in Flutter:**
```dart
import 'package:flutter_stripe/flutter_stripe.dart';

// Initialize in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Stripe.publishableKey = 'pk_test_your_key_here';
  await Stripe.instance.applySettings();
  
  runApp(MyApp());
}

// Create payment intent
final paymentMethod = await Stripe.instance.createPaymentMethod(
  params: PaymentMethodParams.card(
    paymentMethodData: PaymentMethodData(
      billingDetails: BillingDetails(
        email: 'email@example.com',
      ),
    ),
  ),
);
```

### Option 2: Use pay Package (Apple Pay + Google Pay)

```yaml
dependencies:
  pay: ^2.0.0
```

### Option 3: Use in_app_purchase (For App Store/Play Store Payments)

```yaml
dependencies:
  in_app_purchase: ^3.1.0
```

## Backend Requirements

You'll need a backend API to:
1. Create payment intents
2. Store payment information securely
3. Handle webhooks from Stripe

Example endpoint:
```
POST /api/payments/create-intent
{
  "amount": 2500,  // in cents
  "currency": "usd",
  "customerId": "user_123"
}
```

## Security Best Practices

- ✅ Never store API secret keys in the app
- ✅ Use publishable keys only in the frontend
- ✅ Create payment intents on your backend
- ✅ Validate payments server-side
- ✅ Use webhooks to confirm payments

## Testing

Use Stripe test cards:
- Success: `4242 4242 4242 4242`
- Decline: `4000 0000 0000 0002`
- Auth required: `4000 0027 6000 3184`

## Documentation

- flutter_stripe: https://pub.dev/packages/flutter_stripe
- Stripe Docs: https://stripe.com/docs
