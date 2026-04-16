// #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//     import CoreFoundation
//
//     func getHighResTime() -> Double {
//         CFAbsoluteTimeGetCurrent()
//     }
//
// #elseif os(Linux)
//     import Glibc
//
//     func getHighResTime() -> Double {
//         var tv = timeval()
//         gettimeofday(&tv, nil)
//         return Double(tv.tv_sec) + Double(tv.tv_usec) / 1_000_000.0
//     }
//
// #else
//     func getHighResTime() -> Double {
//         Date().timeIntervalSince1970
//     }
//
// #endif
