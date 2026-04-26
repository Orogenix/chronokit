.PHONY: building cleaning build clean test test-dev td test-integration ti test-prop tp benchmark lint fmt ensure-placeholder compile-tz gen-tz update-tz clean-tz

# ---- Colors ----

GREEN := \033[0;32m
CYAN := \033[0;36m
YELLOW := \033[1;33m
RED := \033[0;31m
RESET := \033[0m

# ---- Build  ----

building:
	@echo "$(CYAN)>>> Building Swift Package in Debug Configuration...$(RESET)"
	@swift build

cleaning:
	@echo "$(YELLOW)>>> Cleaning Swift Package Derived Data...$(RESET)"
	@swift package clean
	@echo "$(GREEN)>>> Success Cleaning Swift Package Derived Data...$(RESET)"

build:
	@clear
	@$(MAKE) building

clean:
	@clear
	@$(MAKE) cleaning

# ---- Testings ----

test:
	@clear
	@echo "$(CYAN)>>> Running Unit Tests in Release Configuration...$(RESET)"
	@swift test --configuration release

test-dev td:
	@clear
	@echo "$(CYAN)>>> Running Unit Tests in Development Configuration...$(RESET)"
	@swift test \
		--filter ChronoCoreTests \
		--filter ChronoMathTests \
		--filter ChronoFormatterTests \
		--filter ChronoParserTests \
		--filter ChronoSystemTests \
		--filter ChronoTZTests \
		--filter ChronoTZGenTests

test-integration ti:
	@clear
	@echo "$(CYAN)>>> Running Integration Tests...$(RESET)"
	@swift test --filter ChronoIntegrationTests

test-prop tp:
	@clear
	@echo "$(CYAN)>>> Running Property Tests...$(RESET)"
	@swift test --filter ChronoPropertyTests

benchmark:
	@clear
	@echo "$(CYAN)>>> Running Performance Benchmark (ChronoBenchmark) in Release Configuration...$(RESET)"
	@swift run --configuration release ChronoBenchmark

# ---- Format ----

lint:
	@clear
	@$(MAKE) cleaning
	@$(MAKE) building
	@echo "$(YELLOW)>>> Running SwiftLint for Code Style Check...$(RESET)"
	@swiftlint

fmt:
	@clear
	@$(MAKE) cleaning
	@$(MAKE) building
	@echo "$(YELLOW)>>> Running SwiftFormat for Code Style Check...$(RESET)"
	@swiftformat --swift-version 6.2 .

# ---- TZ ----

TZDB_DIR = ./Tools/tzdb
ZIC = $(TZDB_DIR)/zic
COMPILED_TZDB = .build/compiled_tzdb

TZ_SOURCE_FILES = \
    $(TZDB_DIR)/africa \
    $(TZDB_DIR)/antarctica \
    $(TZDB_DIR)/asia \
    $(TZDB_DIR)/australasia \
    $(TZDB_DIR)/europe \
    $(TZDB_DIR)/northamerica \
    $(TZDB_DIR)/southamerica \
    $(TZDB_DIR)/etcetera \
    $(TZDB_DIR)/backward \
    $(TZDB_DIR)/factory

OUT_DIR = ./Sources/ChronoTZ
OUT_BIN_TZDB = $(OUT_DIR)/Resources/iana.tzdb
OUT_C_TZDB = $(OUT_DIR)/iana
OUT_SWIFT_TZDB = $(OUT_DIR)/IANA.swift
OUT_BIN_TEST_TZDB = ./Tests/Integration/Resources/iana.tzdb

FORMAT ?= bin

ifeq ($(FORMAT),bin)
	OUT_PATH = $(OUT_BIN_TZDB)
else ifeq ($(FORMAT),c)
	OUT_PATH = $(OUT_C_TZDB)
else ifeq ($(FORMAT),swift)
	OUT_PATH = $(OUT_SWIFT_TZDB)
else
	$(error Invalid FORMAT "$(FORMAT)". Must be 'bin' or 'swift')
endif

ensure-placeholder:
	@mkdir -p $(dir $(OUT_BIN_TZDB))
	@if [ ! -f $(OUT_BIN_TZDB) ]; then \
		echo "Creating placeholder for $(OUT_BIN_TZDB)..."; \
		touch $(OUT_BIN_TZDB); \
	fi
	@mkdir -p $(dir $(OUT_BIN_TEST_TZDB))
	@if [ ! -f $(OUT_BIN_TEST_TZDB) ]; then \
		echo "Creating placeholder for $(OUT_BIN_TEST_TZDB)..."; \
		touch $(OUT_BIN_TEST_TZDB); \
	fi

$(ZIC):
	@echo "Building zic using IANA's Makefile..."
	@$(MAKE) -C $(TZDB_DIR) zic

compile-tz: 
	$(ZIC)
	@mkdir -p $(COMPILED_TZDB)
	@echo "Compiling IANA source with zic..."
	@$(ZIC) -d $(COMPILED_TZDB) $(TZ_SOURCE_FILES)

gen-tz: 
	@$(MAKE) ensure-placeholder
	@$(MAKE) compile-tz
	@echo "Generating $(FORMAT) output at $(OUT_PATH) & $(OUT_BIN_TEST_TZDB)..."
	@swift run ChronoTZGen \
		--input $(COMPILED_TZDB) \
		--output $(OUT_PATH) \
		--format $(FORMAT)
	@swift run ChronoTZGen \
		--input $(COMPILED_TZDB) \
		--output $(OUT_BIN_TEST_TZDB) \
		--format $(FORMAT)

update-tz:
	@echo "$(CYAN)>>> Fetching latest IANA data...$(RESET)"
	@git submodule update --remote $(TZDB_DIR)
	@$(MAKE) clean-tz
	@$(MAKE) gen-tz FORMAT=bin
	@echo "$(CYAN)>>> TZDB updated and recompiled.$(RESET)"

clean-tz:
	@echo "Cleaning output artifacts..."
	@rm -f $(OUT_BIN_TZDB) $(OUT_C_TZDB).c $(OUT_C_TZDB).h $(OUT_SWIFT_TZDB)
	@rm -rf $(COMPILED_TZDB)
