import SwiftUI

struct CurrencyField: View {
    let label: String
    let unit: String
    @Binding var value: Double
    var placeholder: String = "0"

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                Spacer()
                Text(unit)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color(red: 0.812, green: 0.878, blue: 1.0))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(TCTheme.accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(Color(red: 0.62, green: 0.737, blue: 1.0).opacity(0.25), lineWidth: 1)
                    )
            }

            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .font(.system(size: 16))
                .foregroundStyle(TCTheme.text)
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    if focused {
                        text = value == 0 ? "" : formatNumber(value)
                    } else {
                        value = parseNumber(text)
                        text = formatNumber(value)
                    }
                }
                .onAppear {
                    text = formatNumber(value)
                }
        }
        .tcField()
    }

    private func formatNumber(_ val: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: val)) ?? "0"
    }

    private func parseNumber(_ str: String) -> Double {
        let cleaned = str.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleaned) ?? 0
    }
}

struct PercentField: View {
    let label: String
    @Binding var value: Double

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                Spacer()
                Text("%")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color(red: 0.812, green: 0.878, blue: 1.0))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(TCTheme.accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(Color(red: 0.62, green: 0.737, blue: 1.0).opacity(0.25), lineWidth: 1)
                    )
            }

            TextField("0.0", text: $text)
                .keyboardType(.decimalPad)
                .font(.system(size: 16))
                .foregroundStyle(TCTheme.text)
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    if focused {
                        text = value == 0 ? "" : String(format: "%.2f", value)
                    } else {
                        value = Double(text) ?? 0
                        text = String(format: "%.2f", value)
                    }
                }
                .onAppear {
                    text = String(format: "%.2f", value)
                }
        }
        .tcField()
    }
}

struct TermPicker: View {
    @Binding var selectedTerm: Int
    let terms: [Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Loan Term")
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                Spacer()
                Text("mo")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color(red: 0.812, green: 0.878, blue: 1.0))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(TCTheme.accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(Color(red: 0.62, green: 0.737, blue: 1.0).opacity(0.25), lineWidth: 1)
                    )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(terms, id: \.self) { term in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTerm = term
                            }
                        } label: {
                            Text("\(term)")
                                .font(.system(size: 14, weight: selectedTerm == term ? .bold : .medium))
                                .foregroundStyle(selectedTerm == term ? .white : TCTheme.muted)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    selectedTerm == term
                                        ? AnyShapeStyle(TCTheme.accentGradient)
                                        : AnyShapeStyle(TCTheme.panelAlt.opacity(0.5))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(
                                            selectedTerm == term ? .clear : TCTheme.line,
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .tcField()
    }
}
