// import ChronoMath
//
// private func runRoundTripIdentityCheck(_ yStart: Int64, _ yEnd: Int64) -> Int64 {
//     var prevDays: Int64 = daysFromCivil(year: yStart, month: 1, day: 1) - 1
//     precondition(prevDays < 0)
//
//     var prevWd: Int = weekday(from: prevDays)
//     precondition(prevWd >= 0 && prevWd <= 6, "Prev weekday out of range at day \(prevDays)")
//
//     for year in yStart ... yEnd {
//         for month: UInt8 in 1 ... 12 {
//             for day: UInt8 in 1 ... lastDayOfMonth(year, month) {
//                 let days = daysFromCivil(year: year, month: month, day: day)
//                 precondition(days == prevDays + 1, "Serial continuity failure at \(year)-\(month)-\(day)")
//
//                 let civil = civilDate(from: days)
//                 precondition(civil.year == year, "Year mismatch for \(year)-\(month)-\(day)")
//                 precondition(civil.month == month, "Month mismatch for \(year)-\(month)-\(day)")
//                 precondition(civil.day == day, "Day mismatch for \(year)-\(month)-\(day)")
//
//                 let wd = weekday(from: days)
//                 precondition(wd >= 0 && wd <= 6, "Weekday out of range at day \(days)")
//                 precondition(wd == nextWeekday(prevWd), "Next weekday failure at day \(days)")
//                 precondition(prevWd == prevWeekday(wd), "Prev weekday failure at day \(days)")
//
//                 prevDays = days
//                 prevWd = wd
//             }
//         }
//     }
//
//     return daysFromCivil(year: yEnd, month: 12, day: 31) - daysFromCivil(year: yStart, month: 1, day: 1) + 1
// }
//
// func runCivilDateBenchmark() {
//     let yStart: Int64 = -1_000_000
//     let yEnd: Int64 = 1_000_000
//
//     let t0 = getHighResTime()
//     let totalDaysTested = runRoundTripIdentityCheck(yStart, yEnd) // Call your core logic
//     let t1 = getHighResTime()
//
//     let timeElapsed = t1 - t0
//     let timePerDay = timeElapsed / Double(totalDaysTested)
//
//     print("✅ 2 Million Year Stress Test Complete.")
//     print("Time elapsed: \(timeElapsed) seconds")
//     print("Total day tested: \(totalDaysTested)")
//     print("Time per day tested: \(timePerDay) seconds")
// }
