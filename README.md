<h1 align="center">
  ChronoKit
</h1>

<p align="center">
  High-performance, zero-dependency date and time primitives for Swift.
</p>

<br><br>

ChronoKit is designed for systems where runtime efficiency and binary size are critical, providing an alternative to `Foundation.Date` with zero dependencies.

## Features

- **Core Types**: Strictly typed primitives (`Instant`, `NaiveDate`, `NaiveTime`, `NaiveDateTime`, `DateTime<TZ>`) to enforce correct time representation.
- **Standards Compliant**: Native support for **RFC 3339**, **RFC 5322**, and **RFC 2822** (legacy support).
- **Zero-Allocation**: Custom byte-level parser and formatter designed for high-throughput serialization and logging.
- **IANA Integration**: Optional, high-performance timezone support with memory-pooled lookups and BLOB deduplication.

## Quick Start

```swift
import ChronoKit
import ChronoTZ

/// Parse an RFC 3339 string
let instant = Instant(rfc3339: "2026-04-26T12:00:00Z")!

/// Convert to wall-clock time
let naive = try! instant.naiveDateTime(in: "America/New_York")

/// Convert to zoned date time
let datetime = instant.dateTime(in: FixedOffset.utc)

print(naive) // 2026-04-26T08:00:00
print(datetime) // 2026-04-26T12:00:00Z
```

## Supported Standards

| Standard     | Description                                      |
| ------------ | ------------------------------------------------ |
| **RFC 3339** | Date and Time on the Internet (Timestamps)       |
| **RFC 5322** | Internet Message Format                          |
| **RFC 2822** | Obsolete Internet Message Format (Legacy Bridge) |

## Performance Philosophy

ChronoKit avoids `Foundation`'s overhead by using direct memory buffers for parsing and formatting.
It is designed to be embedded in low-level systems, CLI tools, and performance-sensitive services.

## Acknowledgments

Calendrical logic built upon the foundational work of [Howard Hinnant](https://howardhinnant.github.io/date_algorithms.html).
His efficient algorithms for date and time calculation serve as the core of **ChronoKit**.
