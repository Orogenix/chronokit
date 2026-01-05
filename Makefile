.PHONY: building cleaning build clean test benchmark lint
	
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
