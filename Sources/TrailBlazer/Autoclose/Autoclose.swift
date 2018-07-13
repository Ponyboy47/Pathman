//
//  Autoclose.swift
//  Cdirent
//
//  Created by Jacob Williams on 7/3/18.
//

func autoclose<PathType: Openable & Hashable & Comparable, OpenType: Equatable>(_ dict: DateSortedDescriptors<PathType, OpenType>, percentage: Double = -1.0, conditions: Conditions, priority: SortPriority = .added, min: Double = 0.0, max: Double = -1.0) {
    let maxCount: Int = max == -1.0 ? dict.count : max < 1.0 ? Int(Double(dict.count) * max) : Int(max)
    let minCount: Int = min == -1.0 ? dict.count : min < 1.0 ? Int(Double(dict.count) * min) : Int(min)
    let percentageCount: Int = percentage == -1.0 ? dict.count : percentage < 1.0 ? Int(Double(dict.count) * percentage) : Int(percentage)

    precondition(min <= max)
    let max = Swift.max(maxCount, percentageCount)

    var closed = 0
    for (path, _) in dict.matching(conditions, priority: priority) {
        if closed >= minCount {
            guard closed < max else { return }
        }
        do {
            try path.close()
            closed += 1
        } catch {}
    }
}

enum Time {
    case milliseconds(Int)
    case seconds(Int)
    case minutes(Int)
    case hours(Int)
    case days(Int)

    var timeInterval: Double {
        let interval: Double
        switch self {
        case .milliseconds(let milli): interval = Double(milli) / 1000.0
        case .seconds(let sec): interval = Double(sec)
        case .minutes(let min): interval = Double(min * 60)
        case .hours(let hour): interval = Double(hour * 60 * 60)
        case .days(let day): interval = Double(day * 24 * 60 * 60)
        }
        return -1.0 * interval
    }
}

struct Conditions {
    enum Period {
        case older
        case newer
    }

    var period: Period
    var time: Time
    var threshold: Double = -1.0
    var minCount: Int = 1

    private init(period: Period, time: Time) {
        self.period = period
        self.time = time
    }

    private init(period: Period, time: Time, threshold: Double) {
        self.init(period: period, time: time)
        self.threshold = threshold
    }

    private init(period: Period, time: Time, minCount: Int) {
        self.init(period: period, time: time)
        self.minCount = minCount
    }

    private init(period: Period, time: Time, threshold: Double, minCount: Int) {
        self.init(period: period, time: time)
        self.threshold = threshold
        self.minCount = minCount
    }

    static func older(than time: Time, threshold: Double = -1.0, minCount: Int = 1) -> Conditions {
        return Conditions(period: .older, time: time, threshold: threshold, minCount: minCount)
    }

    static func newer(than time: Time, threshold: Double = -1.0, minCount: Int = 1) -> Conditions {
        return Conditions(period: .newer, time: time, threshold: threshold, minCount: minCount)
    }
}
