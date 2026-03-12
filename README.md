# TrueCost Auto

**TrueCost Auto** is a native iOS SwiftUI app that goes beyond a simple car payment calculator. It gives car buyers a **Deal Verdict** — a clear, explainable assessment of whether a vehicle deal fits their budget — powered by the proprietary **DealFit Index™**.

---

## What Makes TrueCost Auto Different

Most car-cost apps show you a monthly payment and call it done. TrueCost Auto is purpose-built to help buyers understand the *true* cost of ownership and whether a specific deal is actually affordable for them.

### 1. Deal Check Wizard (not a form)
Instead of a long input screen, the app guides users through a **4-step guided wizard**:
1. **Budget** — set a monthly spending target and optional income
2. **Deal** — vehicle price, down payment, trade-in, fees, APR, and term
3. **Usage** — insurance, fuel (manual or via built-in estimator), maintenance, and depreciation
4. **Review** — summary before running the analysis

### 2. Verdict + DealFit Index™
Results are shown as a **Verdict** (Good Deal / Caution / Not Recommended) derived from the **DealFit Index™** — a proprietary 0–100 affordability score that weights:
- Cost-to-income ratio (50%)
- Interest burden relative to principal (30%)
- Loan term length penalty (20%)

This is documented and transparent — users can tap "Methodology" to see every formula.

### 3. Affordability Mode (reverse calculator)
Unique to TrueCost Auto: users enter their **monthly budget** and the app **computes the maximum vehicle price** they can afford, given APR, term, down payment, and estimated running costs. No other generic calculator template includes this flow.

### 4. Explainability & Recommendations
The Verdict screen shows:
- **Why** this verdict was given (cost driver breakdown by percentage)
- **What to change** — actionable recommendations (e.g., "Shorten to 60-month term to save $X in interest," "High APR — shopping for 6.99% saves $Y")
- A **custom stacked bar chart** (pure SwiftUI, zero external dependencies) showing loan vs. depreciation vs. running cost composition

### 5. Methodology & Transparency Screen
A dedicated **Methodology** screen documents every formula used — amortization, depreciation model, DealFit Index scoring, Verdict thresholds, and Affordability Mode math. This is rare in consumer finance apps.

### 6. DealFit Pro (One-Time Purchase)
Selected advanced features (3-vehicle comparison mode, advanced export) are gated behind a **single non-consumable one-time purchase** via StoreKit 2. No subscription.

---

## Architecture

```
TrueCostAuto/
├── TrueCostAutoApp.swift          # Entry point; provides Store, ViewModel, StoreKitManager
├── ContentView.swift              # Tab nav: Check / Garage / About
│
├── Models/
│   ├── Vehicle.swift              # Vehicle data (Codable, includes monthlyBudget)
│   └── CalculationResult.swift    # Results + VerdictRating + CostDriver + AffordabilityResult
│
├── Services/
│   ├── CostCalculator.swift       # Amortization, depreciation, DealFit Index, affordability
│   ├── VehicleStore.swift         # UserDefaults persistence
│   └── StoreKitManager.swift      # StoreKit 2 one-time purchase manager
│
├── ViewModels/
│   └── VehicleViewModel.swift     # App state, wizard flow, affordability mode
│
├── Views/
│   ├── Wizard/
│   │   └── DealCheckWizardView.swift   # 4-step guided input wizard
│   ├── Verdict/
│   │   ├── VerdictView.swift           # Primary results: verdict, DealFit Index, chart
│   │   ├── CostStackChartView.swift    # Custom stacked bar chart (no dependencies)
│   │   └── WhatToChangeView.swift      # Actionable recommendations engine
│   ├── Affordability/
│   │   └── AffordabilityView.swift     # Reverse affordability calculator
│   ├── Paywall/
│   │   └── PaywallView.swift           # One-time unlock screen
│   ├── Results/                        # Legacy: DetailedBreakdown, Compare, Share, etc.
│   ├── Input/                          # Legacy: full-form input (still accessible)
│   ├── Components/
│   │   ├── CurrencyField.swift
│   │   └── AppLogo.swift
│   ├── OnboardingView.swift            # Updated: Verdict / Affordability Mode / DealFit Index
│   └── MethodologyView.swift           # Formula transparency screen
│
└── Extensions/
    └── Theme.swift                # Design system (colors, gradients, modifiers)
```

---

## Calculation Methodology

See `Views/MethodologyView.swift` or the in-app Methodology screen for full details. Summary:

- **Amortization**: `P = payment × [(1+r)^n − 1] / [r × (1+r)^n]`
- **Depreciation**: compound annual `value = price × (1 − rate)^year`, averaged monthly
- **True Monthly Cost**: loan payment + running costs + monthly depreciation
- **DealFit Index™**: `100 − weighted_penalty`, where penalty = cost-to-income (50%) + interest burden (30%) + term penalty (20%)
- **Verdict**: DealFit ≥ 70 → Good, 40–69 → Caution, < 40 → Not Recommended
- **Affordability Mode**: `maxFinanced = maxPayment × [(1+r)^n − 1] / [r × (1+r)^n]`

---

## Non-App Files

The `web-preview/` directory contains a static HTML preview page and Docker/nginx files used during design iteration. **These are not part of the iOS app bundle and have no effect on App Store submissions.**

---

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+
- StoreKit 2 (included in iOS 17)

---

## App Store Differentiation (re: Guideline 4.3(a))

This app was redesigned following an App Store Review rejection under Guideline 4.3(a) (Spam). The redesign addresses the concern by:

1. **Replacing the generic Calculator/Saved/Settings tab structure** with a purpose-built Home → Deal Check → Verdict flow
2. **Adding Affordability Mode** (reverse calculator) — a distinct feature not found in template-based vehicle cost apps
3. **Introducing the DealFit Index™** as a proprietary, documented scoring system that replaces the generic "Smart Score" label
4. **Adding a Verdict UX** (Good/Caution/Not Recommended) with explainability and personalized recommendations
5. **Publishing the methodology** in a dedicated in-app screen so Apple reviewers and users can verify originality
6. **Moving web-only artifacts** (preview.html, Dockerfile) to a clearly separate `web-preview/` directory outside the iOS app target
