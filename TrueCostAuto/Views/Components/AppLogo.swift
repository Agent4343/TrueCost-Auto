import SwiftUI

struct AppLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Gradient background
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(TCTheme.accentGradient)

            // Shine overlay
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.22), location: 0),
                            .init(color: .white.opacity(0.06), location: 0.35),
                            .init(color: .clear, location: 0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Gear + sync mark
            ShiftSyncMark()
                .fill(.white.opacity(0.95))
                .frame(width: size * 0.62, height: size * 0.62)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - ShiftSync Mark (Gear with Sync Arrows)

struct ShiftSyncMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let unit = min(rect.width, rect.height) / 2

        // --- Outer gear ring ---
        let outerR = unit
        let innerR = unit * 0.78
        let toothCount = 8
        let anglePerTooth = (2.0 * .pi) / Double(toothCount)
        let toothHalf = anglePerTooth * 0.28

        for i in 0..<toothCount {
            let centerAngle = Double(i) * anglePerTooth - .pi / 2

            // Tooth outer arc
            let tStart = centerAngle - toothHalf
            let tEnd = centerAngle + toothHalf
            if i == 0 {
                let x = cx + CGFloat(cos(tStart)) * outerR
                let y = cy + CGFloat(sin(tStart)) * outerR
                path.move(to: CGPoint(x: x, y: y))
            }
            path.addArc(center: CGPoint(x: cx, y: cy), radius: outerR,
                        startAngle: .radians(tStart), endAngle: .radians(tEnd), clockwise: false)

            // Valley (inner arc)
            let vStart = tEnd
            let vEnd = centerAngle + anglePerTooth - toothHalf
            let vsx = cx + CGFloat(cos(vStart)) * innerR
            let vsy = cy + CGFloat(sin(vStart)) * innerR
            path.addLine(to: CGPoint(x: vsx, y: vsy))
            path.addArc(center: CGPoint(x: cx, y: cy), radius: innerR,
                        startAngle: .radians(vStart), endAngle: .radians(vEnd), clockwise: false)

            // Back up to next tooth
            let nsx = cx + CGFloat(cos(vEnd)) * outerR
            let nsy = cy + CGFloat(sin(vEnd)) * outerR
            path.addLine(to: CGPoint(x: nsx, y: nsy))
        }
        path.closeSubpath()

        // --- Hollow center (ring cutout via even-odd) ---
        let holeR = unit * 0.52
        path.addEllipse(in: CGRect(x: cx - holeR, y: cy - holeR,
                                    width: holeR * 2, height: holeR * 2))

        // --- Sync arrows inside the hole ---
        let arrowR = unit * 0.36
        let stroke = unit * 0.13
        let arrowLen: CGFloat = unit * 0.18

        // Top arrow: arc from 210° to 330°
        addArrowArc(to: &path, center: CGPoint(x: cx, y: cy),
                     radius: arrowR, stroke: stroke,
                     startDeg: 210, endDeg: 330, arrowSize: arrowLen)

        // Bottom arrow: arc from 30° to 150°
        addArrowArc(to: &path, center: CGPoint(x: cx, y: cy),
                     radius: arrowR, stroke: stroke,
                     startDeg: 30, endDeg: 150, arrowSize: arrowLen)

        return path
    }

    private func addArrowArc(to path: inout Path,
                              center: CGPoint, radius: CGFloat, stroke: CGFloat,
                              startDeg: Double, endDeg: Double, arrowSize: CGFloat) {
        let startRad = startDeg * .pi / 180
        let endRad = endDeg * .pi / 180

        // Outer edge of arc stroke
        let outerR = radius + stroke / 2
        let innerR = radius - stroke / 2

        // Build thick arc as a filled shape
        var arc = Path()

        // Outer arc (forward)
        arc.addArc(center: center, radius: outerR,
                   startAngle: .radians(startRad), endAngle: .radians(endRad), clockwise: false)

        // Inner arc (reverse)
        arc.addArc(center: center, radius: innerR,
                   startAngle: .radians(endRad), endAngle: .radians(startRad), clockwise: true)
        arc.closeSubpath()

        path.addPath(arc)

        // Arrowhead at end of arc
        let tipAngle = endRad
        let tipX = center.x + CGFloat(cos(tipAngle)) * radius
        let tipY = center.y + CGFloat(sin(tipAngle)) * radius

        // Arrow points outward along the arc tangent
        let tangent = tipAngle + .pi / 2  // perpendicular to radius = tangent direction
        let spreadAngle: CGFloat = 0.45
        let backLeft = CGFloat(tangent) - .pi + spreadAngle
        let backRight = CGFloat(tangent) - .pi - spreadAngle

        var arrow = Path()
        arrow.move(to: CGPoint(x: tipX, y: tipY))
        arrow.addLine(to: CGPoint(
            x: tipX + CGFloat(cos(backLeft)) * arrowSize,
            y: tipY + CGFloat(sin(backLeft)) * arrowSize
        ))
        arrow.addLine(to: CGPoint(
            x: tipX + CGFloat(cos(backRight)) * arrowSize,
            y: tipY + CGFloat(sin(backRight)) * arrowSize
        ))
        arrow.closeSubpath()

        path.addPath(arrow)
    }
}

#Preview {
    ZStack {
        TCTheme.bg.ignoresSafeArea()

        VStack(spacing: 30) {
            AppLogo(size: 120)
            AppLogo(size: 80)
            AppLogo(size: 42)
            AppLogo(size: 28)
        }
    }
}
