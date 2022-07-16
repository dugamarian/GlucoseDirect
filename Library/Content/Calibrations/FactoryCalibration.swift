//
//  FactoryCalibration.swift
//  GlucoseDirect
//

import Foundation

// MARK: - FactoryCalibration

struct FactoryCalibration: Codable {
    // MARK: Lifecycle

    init(i1: Int, i2: Int, i3: Double, i4: Double, i5: Double, i6: Double) {
        self.i1 = i1
        self.i2 = i2
        self.i3 = i3
        self.i4 = i4
        self.i5 = i5
        self.i6 = i6
    }

    // MARK: Internal

    let i1: Int
    let i2: Int
    let i3: Double
    let i4: Double
    let i5: Double
    let i6: Double

    var description: String {
        "{ i1: \(i1), i2: \(i2), i3: \(i3), i4: \(i4), i5: \(i5), i6: \(i6) }"
    }

    func calibrate(rawValue: Double, rawTemperature: Double, rawTemperatureAdjustment: Double) -> Double {
        let x: Double = 1000 + 71500
        let y: Double = 1000
        let ca = 0.0009180023
        let cb = 0.0001964561
        let cc = 0.0000007061775
        let cd = 0.00000005283566
        let rLeft = rawTemperature * x
        let rRight = rawTemperatureAdjustment + Double(i6)

        let R = (rLeft / rRight) - y
        let logR = log(R)
        let d = pow(logR, 3) * cd + pow(logR, 2) * cc + logR * cb + ca

        let temperature = 1 / d - 273.15

        let g1 = 65.0 * (rawValue - Double(i3)) / Double(i4 - i3)
        let g2 = pow(1.045, 32.5 - temperature)

        let g3 = g1 * g2

        let v1 = t1[i2 - 1]
        let v2 = t2[i2 - 1]

        return round((g3 - v1) / v2)
    }

    // MARK: Private
}

extension FactoryCalibration {
    static func libreStyleCalibration(fram: Data) -> FactoryCalibration {
        let i1 = readBits(fram, 2, 0, 3)
        let i2 = readBits(fram, 2, 3, 0xa)

        var i3 = Double(readBits(fram, 0x150, 0, 8))
        if readBits(fram, 0x150, 0x21, 1) != 0 {
            i3 = -i3
        }

        let i4 = Double(readBits(fram, 0x150, 8, 0xe))
        let i5 = Double(readBits(fram, 0x150, 0x28, 0xc) << 2)
        let i6 = Double(readBits(fram, 0x150, 0x34, 0xc) << 2)

        return FactoryCalibration(i1: i1, i2: i2, i3: i3, i4: i4, i5: i5, i6: i6)
    }

    static func libreProCalibration(fram: Data) -> FactoryCalibration {
        let b = 14 + 42
        let i1 = readBits(fram, 26, 0, 3)
        let i2 = readBits(fram, 26, 3, 0xa)

        var i3 = Double(readBits(fram, b, 0, 8))
        if readBits(fram, b, 0x21, 1) != 0 {
            i3 = -i3
        }

        let i4 = Double(readBits(fram, b, 8, 0xe))
        let i5 = Double(readBits(fram, b, 0x28, 0xc) << 2)
        let i6 = Double(readBits(fram, b, 0x34, 0xc) << 2)

        return FactoryCalibration(i1: i1, i2: i2, i3: i3, i4: i4, i5: i5, i6: i6)
    }
}

private func readBits(_ buffer: Data, _ byteOffset: Int, _ bitOffset: Int, _ bitCount: Int) -> Int {
    guard bitCount != 0 else {
        return 0
    }

    var res = 0
    for i in 0 ..< bitCount {
        let totalBitOffset = byteOffset * 8 + bitOffset + i
        let byte = Int(floor(Float(totalBitOffset) / 8))
        let bit = totalBitOffset % 8
        if byte >= 0, byte < buffer.count, ((Int(buffer[byte]) >> bit) & 0x1) == 1 {
            res = res | (1 << i)
        }
    }

    return res
}

private let t1 = [
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
    1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
]

private let t2 = [
    0.037744199999999999, 0.037744199999999999, 0.037744199999999999, 0.037744199999999999, 0.037744199999999999, 0.037744199999999999, 0.037744199999999999, 0.037744199999999999,
    0.038121700000000001, 0.038121700000000001, 0.038121700000000001, 0.038121700000000001, 0.038121700000000001, 0.038121700000000001, 0.038121700000000001, 0.038121700000000001,
    0.0385029, 0.0385029, 0.0385029, 0.0385029, 0.0385029, 0.0385029, 0.0385029, 0.0385029,
    0.038887900000000003, 0.038887900000000003, 0.038887900000000003, 0.038887900000000003, 0.038887900000000003, 0.038887900000000003, 0.038887900000000003, 0.038887900000000003,
    0.039276800000000001, 0.039276800000000001, 0.039276800000000001, 0.039276800000000001, 0.039276800000000001, 0.039276800000000001, 0.039276800000000001, 0.039276800000000001,
    0.039669599999999999, 0.039669599999999999, 0.039669599999999999, 0.039669599999999999, 0.039669599999999999, 0.039669599999999999, 0.039669599999999999, 0.039669599999999999,
    0.040066299999999999, 0.040066299999999999, 0.040066299999999999, 0.040066299999999999, 0.040066299999999999, 0.040066299999999999, 0.040066299999999999, 0.040066299999999999,
    0.0404669, 0.0404669, 0.0404669, 0.0404669, 0.0404669, 0.0404669, 0.0404669, 0.0404669,
    0.040871600000000001, 0.040871600000000001, 0.040871600000000001, 0.040871600000000001, 0.040871600000000001, 0.040871600000000001, 0.040871600000000001, 0.040871600000000001,
    0.041280299999999999, 0.041280299999999999, 0.041280299999999999, 0.041280299999999999, 0.041280299999999999, 0.041280299999999999, 0.041280299999999999, 0.041280299999999999,
    0.041693099999999997, 0.041693099999999997, 0.041693099999999997, 0.041693099999999997, 0.041693099999999997, 0.041693099999999997, 0.041693099999999997, 0.041693099999999997,
    0.042110000000000002, 0.042110000000000002, 0.042110000000000002, 0.042110000000000002, 0.042110000000000002, 0.042110000000000002, 0.042110000000000002, 0.042110000000000002,
    0.042531100000000002, 0.042531100000000002, 0.042531100000000002, 0.042531100000000002, 0.042531100000000002, 0.042531100000000002, 0.042531100000000002, 0.042531100000000002,
    0.042956500000000002, 0.042956500000000002, 0.042956500000000002, 0.042956500000000002, 0.042956500000000002, 0.042956500000000002, 0.042956500000000002, 0.042956500000000002,
    0.043386000000000001, 0.043386000000000001, 0.043386000000000001, 0.043386000000000001, 0.043386000000000001, 0.043386000000000001, 0.043386000000000001, 0.043386000000000001,
    0.043819900000000002, 0.043819900000000002, 0.043819900000000002, 0.043819900000000002, 0.043819900000000002, 0.043819900000000002, 0.043819900000000002, 0.043819900000000002,
    0.044258100000000002, 0.044258100000000002, 0.044258100000000002, 0.044258100000000002, 0.044258100000000002, 0.044258100000000002, 0.044258100000000002, 0.044258100000000002,
    0.044700700000000003, 0.044700700000000003, 0.044700700000000003, 0.044700700000000003, 0.044700700000000003, 0.044700700000000003, 0.044700700000000003, 0.044700700000000003,
    0.045147699999999999, 0.045147699999999999, 0.045147699999999999, 0.045147699999999999, 0.045147699999999999, 0.045147699999999999, 0.045147699999999999, 0.045147699999999999,
    0.045599099999999997, 0.045599099999999997, 0.045599099999999997, 0.045599099999999997, 0.045599099999999997, 0.045599099999999997, 0.045599099999999997, 0.045599099999999997,
    0.046055100000000002, 0.046055100000000002, 0.046055100000000002, 0.046055100000000002, 0.046055100000000002, 0.046055100000000002, 0.046055100000000002, 0.046055100000000002,
    0.0465157, 0.0465157, 0.0465157, 0.0465157, 0.0465157, 0.0465157, 0.0465157, 0.0465157,
    0.046980800000000003, 0.046980800000000003, 0.046980800000000003, 0.046980800000000003, 0.046980800000000003, 0.046980800000000003, 0.046980800000000003, 0.046980800000000003,
    0.047450600000000002, 0.047450600000000002, 0.047450600000000002, 0.047450600000000002, 0.047450600000000002, 0.047450600000000002, 0.047450600000000002, 0.047450600000000002,
    0.047925200000000001, 0.047925200000000001, 0.047925200000000001, 0.047925200000000001, 0.047925200000000001, 0.047925200000000001, 0.047925200000000001, 0.047925200000000001,
    0.0484044, 0.0484044, 0.0484044, 0.0484044, 0.0484044, 0.0484044, 0.0484044, 0.0484044,
    0.048888399999999999, 0.048888399999999999, 0.048888399999999999, 0.048888399999999999, 0.048888399999999999, 0.048888399999999999, 0.048888399999999999, 0.048888399999999999,
    0.049377299999999999, 0.049377299999999999, 0.049377299999999999, 0.049377299999999999, 0.049377299999999999, 0.049377299999999999, 0.049377299999999999, 0.049377299999999999,
    0.049871100000000002, 0.049871100000000002, 0.049871100000000002, 0.049871100000000002, 0.049871100000000002, 0.049871100000000002, 0.049871100000000002, 0.049871100000000002,
    0.050369799999999999, 0.050369799999999999, 0.050369799999999999, 0.050369799999999999, 0.050369799999999999, 0.050369799999999999, 0.050369799999999999, 0.050369799999999999,
    0.050873500000000002, 0.050873500000000002, 0.050873500000000002, 0.050873500000000002, 0.050873500000000002, 0.050873500000000002, 0.050873500000000002, 0.050873500000000002,
    0.051382299999999999, 0.051382299999999999, 0.051382299999999999, 0.051382299999999999, 0.051382299999999999, 0.051382299999999999, 0.051382299999999999, 0.051382299999999999,
    0.051896100000000001, 0.051896100000000001, 0.051896100000000001, 0.051896100000000001, 0.051896100000000001, 0.051896100000000001, 0.051896100000000001, 0.051896100000000001,
    0.052415000000000003, 0.052415000000000003, 0.052415000000000003, 0.052415000000000003, 0.052415000000000003, 0.052415000000000003, 0.052415000000000003, 0.052415000000000003,
    0.052939199999999999, 0.052939199999999999, 0.052939199999999999, 0.052939199999999999, 0.052939199999999999, 0.052939199999999999, 0.052939199999999999, 0.052939199999999999,
    0.053468599999999998, 0.053468599999999998, 0.053468599999999998, 0.053468599999999998, 0.053468599999999998, 0.053468599999999998, 0.053468599999999998, 0.053468599999999998,
    0.054003299999999997, 0.054003299999999997, 0.054003299999999997, 0.054003299999999997, 0.054003299999999997, 0.054003299999999997, 0.054003299999999997, 0.054003299999999997,
    0.054543300000000003, 0.054543300000000003, 0.054543300000000003, 0.054543300000000003, 0.054543300000000003, 0.054543300000000003, 0.054543300000000003, 0.054543300000000003,
    0.055088699999999997, 0.055088699999999997, 0.055088699999999997, 0.055088699999999997, 0.055088699999999997, 0.055088699999999997, 0.055088699999999997, 0.055088699999999997,
    0.055639599999999997, 0.055639599999999997, 0.055639599999999997, 0.055639599999999997, 0.055639599999999997, 0.055639599999999997, 0.055639599999999997, 0.055639599999999997,
    0.056196000000000003, 0.056196000000000003, 0.056196000000000003, 0.056196000000000003, 0.056196000000000003, 0.056196000000000003, 0.056196000000000003, 0.056196000000000003,
    0.056758000000000003, 0.056758000000000003, 0.056758000000000003, 0.056758000000000003, 0.056758000000000003, 0.056758000000000003, 0.056758000000000003, 0.056758000000000003,
    0.057325599999999997, 0.057325599999999997, 0.057325599999999997, 0.057325599999999997, 0.057325599999999997, 0.057325599999999997, 0.057325599999999997, 0.057325599999999997,
    0.0578988, 0.0578988, 0.0578988, 0.0578988, 0.0578988, 0.0578988, 0.0578988, 0.0578988,
    0.058477800000000003, 0.058477800000000003, 0.058477800000000003, 0.058477800000000003, 0.058477800000000003, 0.058477800000000003, 0.058477800000000003, 0.058477800000000003,
    0.0590626, 0.0590626, 0.0590626, 0.0590626, 0.0590626, 0.0590626, 0.0590626, 0.0590626,
    0.059653200000000003, 0.059653200000000003, 0.059653200000000003, 0.059653200000000003, 0.059653200000000003, 0.059653200000000003, 0.059653200000000003, 0.059653200000000003,
    0.060249700000000003, 0.060249700000000003, 0.060249700000000003, 0.060249700000000003, 0.060249700000000003, 0.060249700000000003, 0.060249700000000003, 0.060249700000000003,
    0.060852200000000002, 0.060852200000000002, 0.060852200000000002, 0.060852200000000002, 0.060852200000000002, 0.060852200000000002, 0.060852200000000002, 0.060852200000000002,
    0.0614607, 0.0614607, 0.0614607, 0.0614607, 0.0614607, 0.0614607, 0.0614607, 0.0614607,
    0.062075400000000003, 0.062075400000000003, 0.062075400000000003, 0.062075400000000003, 0.062075400000000003, 0.062075400000000003, 0.062075400000000003, 0.062075400000000003,
    0.062696100000000005, 0.062696100000000005, 0.062696100000000005, 0.062696100000000005, 0.062696100000000005, 0.062696100000000005, 0.062696100000000005, 0.062696100000000005,
    0.063323099999999993, 0.063323099999999993, 0.063323099999999993, 0.063323099999999993, 0.063323099999999993, 0.063323099999999993, 0.063323099999999993, 0.063323099999999993,
    0.063956299999999994, 0.063956299999999994, 0.063956299999999994, 0.063956299999999994, 0.063956299999999994, 0.063956299999999994, 0.063956299999999994, 0.063956299999999994,
    0.064595899999999998, 0.064595899999999998, 0.064595899999999998, 0.064595899999999998, 0.064595899999999998, 0.064595899999999998, 0.064595899999999998, 0.064595899999999998,
    0.065241800000000003, 0.065241800000000003, 0.065241800000000003, 0.065241800000000003, 0.065241800000000003, 0.065241800000000003, 0.065241800000000003, 0.065241800000000003,
    0.0658942, 0.0658942, 0.0658942, 0.0658942, 0.0658942, 0.0658942, 0.0658942, 0.0658942,
    0.066553200000000007, 0.066553200000000007, 0.066553200000000007, 0.066553200000000007, 0.066553200000000007, 0.066553200000000007, 0.066553200000000007, 0.066553200000000007,
    0.067218700000000006, 0.067218700000000006, 0.067218700000000006, 0.067218700000000006, 0.067218700000000006, 0.067218700000000006, 0.067218700000000006, 0.067218700000000006,
    0.067890900000000004, 0.067890900000000004, 0.067890900000000004, 0.067890900000000004, 0.067890900000000004, 0.067890900000000004, 0.067890900000000004, 0.067890900000000004,
    0.0685698, 0.0685698, 0.0685698, 0.0685698, 0.0685698, 0.0685698, 0.0685698, 0.0685698,
    0.069255499999999998, 0.069255499999999998, 0.069255499999999998, 0.069255499999999998, 0.069255499999999998, 0.069255499999999998, 0.069255499999999998, 0.069255499999999998,
    0.069948099999999999, 0.069948099999999999, 0.069948099999999999, 0.069948099999999999, 0.069948099999999999, 0.069948099999999999, 0.069948099999999999, 0.069948099999999999,
    0.070647500000000002, 0.070647500000000002, 0.070647500000000002, 0.070647500000000002, 0.070647500000000002, 0.070647500000000002, 0.070647500000000002, 0.070647500000000002,
    0.071354000000000001, 0.071354000000000001, 0.071354000000000001, 0.071354000000000001, 0.071354000000000001, 0.071354000000000001, 0.071354000000000001, 0.071354000000000001, 0.071354000000000001,
    0.072067599999999996, 0.072067599999999996, 0.072067599999999996, 0.072067599999999996, 0.072067599999999996, 0.072067599999999996, 0.072067599999999996, 0.072067599999999996, 0.072067599999999996,
    0.072788199999999997, 0.072788199999999997, 0.072788199999999997, 0.072788199999999997, 0.072788199999999997, 0.072788199999999997, 0.072788199999999997, 0.072788199999999997, 0.072788199999999997,
    0.073516100000000001, 0.073516100000000001, 0.073516100000000001, 0.073516100000000001, 0.073516100000000001, 0.073516100000000001, 0.073516100000000001, 0.073516100000000001, 0.073516100000000001,
    0.074251300000000006, 0.074251300000000006, 0.074251300000000006, 0.074251300000000006, 0.074251300000000006, 0.074251300000000006, 0.074251300000000006, 0.074251300000000006, 0.074251300000000006,
    0.074993799999999999, 0.074993799999999999, 0.074993799999999999, 0.074993799999999999, 0.074993799999999999, 0.074993799999999999, 0.074993799999999999, 0.074993799999999999, 0.074993799999999999,
    0.075743699999999997, 0.075743699999999997, 0.075743699999999997, 0.075743699999999997, 0.075743699999999997, 0.075743699999999997, 0.075743699999999997, 0.075743699999999997, 0.075743699999999997,
    0.076501200000000005, 0.076501200000000005, 0.076501200000000005, 0.076501200000000005, 0.076501200000000005, 0.076501200000000005, 0.076501200000000005, 0.076501200000000005, 0.076501200000000005,
    0.077266199999999993, 0.077266199999999993, 0.077266199999999993, 0.077266199999999993, 0.077266199999999993, 0.077266199999999993, 0.077266199999999993, 0.077266199999999993, 0.077266199999999993,
    0.078038800000000005, 0.078038800000000005, 0.078038800000000005, 0.078038800000000005, 0.078038800000000005, 0.078038800000000005, 0.078038800000000005, 0.078038800000000005, 0.078038800000000005,
    0.078819200000000006, 0.078819200000000006, 0.078819200000000006, 0.078819200000000006, 0.078819200000000006, 0.078819200000000006, 0.078819200000000006, 0.078819200000000006, 0.078819200000000006,
    0.079607399999999995, 0.079607399999999995, 0.079607399999999995, 0.079607399999999995, 0.079607399999999995, 0.079607399999999995, 0.079607399999999995, 0.079607399999999995, 0.079607399999999995,
    0.080403500000000003, 0.080403500000000003, 0.080403500000000003, 0.080403500000000003, 0.080403500000000003, 0.080403500000000003, 0.080403500000000003, 0.080403500000000003, 0.080403500000000003,
    0.081207500000000002, 0.081207500000000002, 0.081207500000000002, 0.081207500000000002, 0.081207500000000002, 0.081207500000000002, 0.081207500000000002, 0.081207500000000002, 0.081207500000000002,
    0.082019599999999998, 0.082019599999999998, 0.082019599999999998, 0.082019599999999998, 0.082019599999999998, 0.082019599999999998, 0.082019599999999998, 0.082019599999999998, 0.082019599999999998,
    0.082839800000000005, 0.082839800000000005, 0.082839800000000005, 0.082839800000000005, 0.082839800000000005, 0.082839800000000005, 0.082839800000000005, 0.082839800000000005, 0.082839800000000005,
    0.083668199999999998, 0.083668199999999998, 0.083668199999999998, 0.083668199999999998, 0.083668199999999998, 0.083668199999999998, 0.083668199999999998, 0.083668199999999998, 0.083668199999999998,
    0.084504899999999994, 0.084504899999999994, 0.084504899999999994, 0.084504899999999994, 0.084504899999999994, 0.084504899999999994, 0.084504899999999994, 0.084504899999999994, 0.084504899999999994,
    0.085349900000000006, 0.085349900000000006, 0.085349900000000006, 0.085349900000000006, 0.085349900000000006, 0.085349900000000006, 0.085349900000000006, 0.085349900000000006, 0.085349900000000006,
    0.086203399999999999, 0.086203399999999999, 0.086203399999999999, 0.086203399999999999, 0.086203399999999999, 0.086203399999999999, 0.086203399999999999, 0.086203399999999999, 0.086203399999999999,
    0.087065500000000004, 0.087065500000000004, 0.087065500000000004, 0.087065500000000004, 0.087065500000000004, 0.087065500000000004, 0.087065500000000004, 0.087065500000000004, 0.087065500000000004,
    0.087936100000000003, 0.087936100000000003, 0.087936100000000003, 0.087936100000000003, 0.087936100000000003, 0.087936100000000003, 0.087936100000000003, 0.087936100000000003, 0.087936100000000003,
    0.088815500000000006, 0.088815500000000006, 0.088815500000000006, 0.088815500000000006, 0.088815500000000006, 0.088815500000000006, 0.088815500000000006, 0.088815500000000006, 0.088815500000000006,
    0.089703599999999994, 0.089703599999999994, 0.089703599999999994, 0.089703599999999994, 0.089703599999999994, 0.089703599999999994, 0.089703599999999994, 0.089703599999999994,
    0.090600700000000006, 0.090600700000000006, 0.090600700000000006, 0.090600700000000006, 0.090600700000000006, 0.090600700000000006, 0.090600700000000006, 0.090600700000000006,
    0.091506699999999996, 0.091506699999999996, 0.091506699999999996, 0.091506699999999996, 0.091506699999999996, 0.091506699999999996, 0.091506699999999996, 0.091506699999999996,
    0.092421699999999996, 0.092421699999999996, 0.092421699999999996, 0.092421699999999996, 0.092421699999999996, 0.092421699999999996, 0.092421699999999996, 0.092421699999999996,
    0.093345999999999998, 0.093345999999999998, 0.093345999999999998, 0.093345999999999998, 0.093345999999999998, 0.093345999999999998, 0.093345999999999998, 0.093345999999999998,
    0.094279399999999999, 0.094279399999999999, 0.094279399999999999, 0.094279399999999999, 0.094279399999999999, 0.094279399999999999, 0.094279399999999999, 0.094279399999999999,
    0.095222200000000007, 0.095222200000000007, 0.095222200000000007, 0.095222200000000007, 0.095222200000000007, 0.095222200000000007, 0.095222200000000007, 0.095222200000000007,
    0.096174399999999993, 0.096174399999999993, 0.096174399999999993, 0.096174399999999993, 0.096174399999999993, 0.096174399999999993, 0.096174399999999993, 0.096174399999999993,
    0.097136200000000006, 0.097136200000000006, 0.097136200000000006, 0.097136200000000006, 0.097136200000000006, 0.097136200000000006, 0.097136200000000006, 0.097136200000000006,
    0.0981075, 0.0981075, 0.0981075, 0.0981075, 0.0981075, 0.0981075, 0.0981075, 0.0981075,
    0.099088599999999999, 0.099088599999999999, 0.099088599999999999, 0.099088599999999999, 0.099088599999999999, 0.099088599999999999, 0.099088599999999999, 0.099088599999999999,
    0.1000795, 0.1000795, 0.1000795, 0.1000795, 0.1000795, 0.1000795, 0.1000795, 0.1000795,
    0.1010803, 0.1010803, 0.1010803, 0.1010803, 0.1010803, 0.1010803, 0.1010803, 0.1010803,
    0.1020911, 0.1020911, 0.1020911, 0.1020911, 0.1020911, 0.1020911, 0.1020911, 0.1020911,
    0.103112, 0.103112, 0.103112, 0.103112, 0.103112, 0.103112, 0.103112, 0.103112,
    0.1041431, 0.1041431, 0.1041431, 0.1041431, 0.1041431, 0.1041431, 0.1041431, 0.1041431,
    0.1051846, 0.1051846, 0.1051846, 0.1051846, 0.1051846, 0.1051846, 0.1051846, 0.1051846,
    0.10623639999999999, 0.10623639999999999, 0.10623639999999999, 0.10623639999999999, 0.10623639999999999, 0.10623639999999999, 0.10623639999999999, 0.10623639999999999,
    0.1072988, 0.1072988, 0.1072988, 0.1072988, 0.1072988, 0.1072988, 0.1072988, 0.1072988,
    0.1083718, 0.1083718, 0.1083718, 0.1083718, 0.1083718, 0.1083718, 0.1083718, 0.1083718,
    0.1094555, 0.1094555, 0.1094555, 0.1094555, 0.1094555, 0.1094555, 0.1094555, 0.1094555,
    0.11055, 0.11055, 0.11055, 0.11055, 0.11055, 0.11055, 0.11055, 0.11055,
    0.1116555, 0.1116555, 0.1116555, 0.1116555, 0.1116555, 0.1116555, 0.1116555, 0.1116555,
    0.1127721, 0.1127721, 0.1127721, 0.1127721, 0.1127721, 0.1127721, 0.1127721, 0.1127721,
    0.1138998, 0.1138998, 0.1138998, 0.1138998, 0.1138998, 0.1138998, 0.1138998, 0.1138998,
    0.1150388, 0.1150388, 0.1150388, 0.1150388, 0.1150388, 0.1150388, 0.1150388, 0.1150388,
    0.11618920000000001, 0.11618920000000001, 0.11618920000000001, 0.11618920000000001, 0.11618920000000001, 0.11618920000000001, 0.11618920000000001, 0.11618920000000001,
    0.1173511, 0.1173511, 0.1173511, 0.1173511, 0.1173511, 0.1173511, 0.1173511, 0.1173511,
    0.11852459999999999, 0.11852459999999999, 0.11852459999999999, 0.11852459999999999, 0.11852459999999999, 0.11852459999999999, 0.11852459999999999, 0.11852459999999999,
    0.11970989999999999, 0.11970989999999999, 0.11970989999999999, 0.11970989999999999, 0.11970989999999999, 0.11970989999999999, 0.11970989999999999, 0.11970989999999999, 0.11970989999999999,
    0.120907, 0.120907, 0.120907, 0.120907, 0.120907, 0.120907, 0.120907, 0.120907, 0.120907,
    0.122116, 0.122116, 0.122116, 0.122116, 0.122116, 0.122116, 0.122116, 0.122116, 0.122116,
    0.12333719999999999, 0.12333719999999999, 0.12333719999999999, 0.12333719999999999, 0.12333719999999999, 0.12333719999999999, 0.12333719999999999, 0.12333719999999999, 0.12333719999999999,
    0.1245706, 0.1245706, 0.1245706, 0.1245706, 0.1245706, 0.1245706, 0.1245706, 0.1245706, 0.1245706,
    0.12581629999999999, 0.12581629999999999, 0.12581629999999999, 0.12581629999999999, 0.12581629999999999, 0.12581629999999999, 0.12581629999999999, 0.12581629999999999, 0.12581629999999999,
    0.1270744, 0.1270744, 0.1270744, 0.1270744, 0.1270744, 0.1270744, 0.1270744, 0.1270744, 0.1270744,
    0.12834519999999999, 0.12834519999999999, 0.12834519999999999, 0.12834519999999999, 0.12834519999999999, 0.12834519999999999, 0.12834519999999999, 0.12834519999999999, 0.12834519999999999,
]
