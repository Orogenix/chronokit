@testable import ChronoSystem
import Testing

struct MutexTests {
    @Test("MutexTests: Sequential Access")
    func sequentialAccess() {
        let mutex = Mutex()
        var value = 0

        mutex.withLock {
            value += 1
        }
        mutex.withLock {
            value += 1
        }

        #expect(value == 2)
    }

    @Test("MutexTests: Concurrent Thread Safety")
    func concurrentAccess() async {
        let mutex = Mutex()
        let counter = Counter(mutex: mutex)
        let iterations = 1000

        // Use a TaskGroup to spawn massive concurrency
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< iterations {
                group.addTask {
                    counter.increment()
                }
            }
        }

        #expect(counter.value == iterations, "Counter should match iterations exactly")
    }

    @Test("MutexTests: Error Propagation")
    func errorPropagation() throws {
        let mutex = Mutex()

        struct ExpectedError: Error {}

        // Ensure that errors thrown inside the lock are propagated correctly
        #expect(throws: ExpectedError.self) {
            try mutex.withLock {
                throw ExpectedError()
            }
        }
    }
}

// MARK: - Helpers

extension MutexTests {
    final class Counter: @unchecked Sendable {
        private let mutex: Mutex
        private(set) var value = 0

        init(mutex: Mutex) {
            self.mutex = mutex
        }

        func increment() {
            mutex.withLock {
                value += 1
            }
        }
    }
}
