#!/bin/bash
# Universal Full-Stack QA Setup Script
# Supports multiple technology stacks for 8.0+ QA scoring

echo "🎯 Universal Full-Stack QA Setup"
echo "================================"

# Detect project type
detect_project_type() {
    local project_type=""
    
    # Frontend detection
    if [ -f "package.json" ]; then
        if grep -q "react" package.json; then
            project_type="${project_type}react "
        elif grep -q "vue" package.json; then
            project_type="${project_type}vue "
        elif grep -q "angular" package.json; then
            project_type="${project_type}angular "
        else
            project_type="${project_type}nodejs "
        fi
    fi
    
    # Backend detection
    if [ -f "go.mod" ]; then
        project_type="${project_type}golang "
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        project_type="${project_type}python "
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        project_type="${project_type}java "
    elif [ -f "Cargo.toml" ]; then
        project_type="${project_type}rust "
    elif [ -f "composer.json" ]; then
        project_type="${project_type}php "
    elif [ -f "Gemfile" ]; then
        project_type="${project_type}ruby "
    fi
    
    echo "$project_type"
}

# JavaScript/TypeScript Setup
setup_javascript_qa() {
    echo "📦 Setting up JavaScript/TypeScript QA..."
    
    cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'node',
  collectCoverage: true,
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 75,
      functions: 80,
      lines: 80
    }
  }
};
EOF
    
    npm install --save-dev jest @types/jest
    npm install --save-dev eslint prettier eslint-config-prettier
    npm install --save-dev @typescript-eslint/parser @typescript-eslint/eslint-plugin
}

# Python Setup
setup_python_qa() {
    echo "🐍 Setting up Python QA..."
    
    cat > pytest.ini << 'EOF'
[tool:pytest]
minversion = 6.0
addopts = 
    --cov=src
    --cov-report=html
    --cov-report=term
    --cov-fail-under=80
    --strict-markers
    -v
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
EOF

    cat > .coveragerc << 'EOF'
[run]
source = src
omit = 
    */tests/*
    */venv/*
    */__pycache__/*
    */migrations/*

[report]
precision = 2
show_missing = True
skip_covered = False

[html]
directory = coverage_html_report
EOF

    cat > requirements-dev.txt << 'EOF'
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-mock>=3.10.0
pytest-asyncio>=0.21.0
pytest-xdist>=3.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0
isort>=5.12.0
pylint>=2.17.0
bandit>=1.7.5
safety>=2.3.0
EOF

    pip install -r requirements-dev.txt
}

# Go Setup
setup_go_qa() {
    echo "🔷 Setting up Go QA..."
    
    cat > Makefile << 'EOF'
.PHONY: test coverage lint security

test:
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

coverage:
	go test -coverprofile=coverage.out ./...
	@echo "Coverage threshold check (80%):"
	@go tool cover -func=coverage.out | grep total | awk '{print $$3}' | sed 's/%//' | \
	awk '{if ($$1 < 80) {print "FAIL: Coverage " $$1 "% is below 80%"; exit 1} else {print "PASS: Coverage " $$1 "% meets 80% threshold"}}'

lint:
	golangci-lint run --enable-all --deadline=5m

security:
	gosec -fmt=json -out=security-report.json ./...
	staticcheck ./...

install-tools:
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/securego/gosec/v2/cmd/gosec@latest
	go install honnef.co/go/tools/cmd/staticcheck@latest
EOF

    cat > .golangci.yml << 'EOF'
linters:
  enable-all: true
  disable:
    - exhaustivestruct
    - golint
    - interfacer
    - maligned
    - scopelint

linters-settings:
  lll:
    line-length: 120
  gocyclo:
    min-complexity: 10
  dupl:
    threshold: 100

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - dupl
        - gosec
EOF

    make install-tools
}

# Java Setup
setup_java_qa() {
    echo "☕ Setting up Java QA..."
    
    if [ -f "pom.xml" ]; then
        cat > pom-qa.xml << 'EOF'
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.10</version>
    <configuration>
        <excludes>
            <exclude>**/config/**</exclude>
            <exclude>**/model/**</exclude>
        </excludes>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        <execution>
            <id>check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
EOF
        echo "📝 Add jacoco plugin to your pom.xml"
    fi
    
    if [ -f "build.gradle" ]; then
        cat > qa.gradle << 'EOF'
apply plugin: 'jacoco'

jacoco {
    toolVersion = "0.8.10"
}

jacocoTestReport {
    reports {
        xml.required = true
        html.required = true
    }
}

jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = 0.80
            }
        }
    }
}

test {
    finalizedBy jacocoTestReport
}

check.dependsOn jacocoTestCoverageVerification
EOF
        echo "📝 Apply qa.gradle in your build.gradle: apply from: 'qa.gradle'"
    fi
}

# Rust Setup
setup_rust_qa() {
    echo "🦀 Setting up Rust QA..."
    
    cat > .cargo/config.toml << 'EOF'
[build]
rustflags = ["-C", "instrument-coverage"]

[env]
CARGO_INCREMENTAL = "0"
RUSTFLAGS = "-Cinstrument-coverage"
LLVM_PROFILE_FILE = "cargo-test-%p-%m.profraw"
EOF

    cat > coverage.sh << 'EOF'
#!/bin/bash
cargo clean
cargo test
grcov . --binary-path ./target/debug/deps/ -s . -t html --branch --ignore-not-existing --ignore '../*' --ignore "/*" -o target/coverage/
echo "Coverage report generated at target/coverage/index.html"
EOF
    
    chmod +x coverage.sh
    cargo install grcov
}

# PHP Setup
setup_php_qa() {
    echo "🐘 Setting up PHP QA..."
    
    cat > phpunit.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<phpunit bootstrap="vendor/autoload.php"
         colors="true"
         verbose="true">
    <testsuites>
        <testsuite name="Test Suite">
            <directory>tests</directory>
        </testsuite>
    </testsuites>
    <coverage>
        <include>
            <directory suffix=".php">src</directory>
        </include>
        <report>
            <html outputDirectory="coverage"/>
            <text outputFile="coverage.txt" showOnlySummary="true"/>
        </report>
    </coverage>
</phpunit>
EOF

    composer require --dev phpunit/phpunit phpstan/phpstan squizlabs/php_codesniffer
}

# Ruby Setup
setup_ruby_qa() {
    echo "💎 Setting up Ruby QA..."
    
    cat > .simplecov << 'EOF'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/vendor/'
  
  minimum_coverage 80
  minimum_coverage_by_file 75
end
EOF

    cat >> Gemfile << 'EOF'
group :development, :test do
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  gem 'rubocop-performance'
end
EOF

    bundle install
}

# Universal QA configuration
create_universal_qa_config() {
    cat > qa-config.json << 'EOF'
{
  "coverage": {
    "statements": 80,
    "branches": 75,
    "functions": 80,
    "lines": 80
  },
  "complexity": {
    "max-cyclomatic": 10,
    "max-cognitive": 15
  },
  "security": {
    "scan-dependencies": true,
    "scan-secrets": true,
    "scan-vulnerabilities": true
  },
  "performance": {
    "max-response-time": 200,
    "max-memory-usage": 512
  },
  "documentation": {
    "require-jsdoc": true,
    "min-coverage": 80
  }
}
EOF
}

# E2E Testing Setup (Universal)
setup_e2e_testing() {
    echo "🌐 Setting up E2E testing..."
    
    if [ -f "package.json" ]; then
        npm install --save-dev cypress @playwright/test
        
        cat > cypress.config.js << 'EOF'
module.exports = {
  e2e: {
    baseUrl: 'http://localhost:3000',
    video: true,
    screenshotOnRunFailure: true,
  }
}
EOF
    fi
}

# CI/CD Configuration
setup_cicd() {
    echo "🔄 Setting up CI/CD..."
    
    mkdir -p .github/workflows
    
    cat > .github/workflows/qa.yml << 'EOF'
name: QA Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Tests
      run: |
        make test || npm test || pytest || cargo test
    
    - name: Check Coverage
      run: |
        make coverage || npm run test:coverage || pytest --cov
    
    - name: Security Scan
      run: |
        make security || npm audit || safety check || cargo audit
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        fail_ci_if_error: true
        verbose: true
EOF
}

# Main execution
main() {
    project_types=$(detect_project_type)
    
    echo "🔍 Detected project types: $project_types"
    echo ""
    
    # Create universal config
    create_universal_qa_config
    
    # Setup based on detected types
    if [[ $project_types == *"nodejs"* ]] || [[ $project_types == *"react"* ]] || [[ $project_types == *"vue"* ]] || [[ $project_types == *"angular"* ]]; then
        setup_javascript_qa
    fi
    
    if [[ $project_types == *"python"* ]]; then
        setup_python_qa
    fi
    
    if [[ $project_types == *"golang"* ]]; then
        setup_go_qa
    fi
    
    if [[ $project_types == *"java"* ]]; then
        setup_java_qa
    fi
    
    if [[ $project_types == *"rust"* ]]; then
        setup_rust_qa
    fi
    
    if [[ $project_types == *"php"* ]]; then
        setup_php_qa
    fi
    
    if [[ $project_types == *"ruby"* ]]; then
        setup_ruby_qa
    fi
    
    # Setup E2E and CI/CD
    setup_e2e_testing
    setup_cicd
    
    echo ""
    echo "✅ QA Setup Complete!"
    echo ""
    echo "📊 Coverage Requirements (8.0 Score):"
    echo "  - Statements: 80%"
    echo "  - Branches: 75%"
    echo "  - Functions: 80%"
    echo "  - Lines: 80%"
    echo ""
    echo "🔧 Next Steps:"
    echo "  1. Run tests for your stack"
    echo "  2. Check coverage reports"
    echo "  3. Fix any failing tests"
    echo "  4. Ensure all thresholds are met"
}

# Run main
main "$@"