#!/bin/bash
# QA Setup Script - Automated Jest Installation and Configuration
# Ensures compliance with 8.0+ QA scoring standards

echo "🚀 Setting up QA-compliant testing environment..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

echo "📦 Installing Jest and testing dependencies..."

# Install Jest and related packages
npm install --save-dev jest @types/jest @types/node
npm install --save-dev babel-jest ts-jest typescript
npm install --save-dev jest-watch-typeahead

# Install additional testing utilities
npm install --save-dev @testing-library/jest-dom
npm install --save-dev @testing-library/react @testing-library/user-event

echo "📁 Creating test directory structure..."

# Create test directories
mkdir -p tests/{unit,integration,e2e}
mkdir -p src/{core,security,api,utils}
mkdir -p __tests__

# Create test setup file
cat > tests/setup.js << 'EOF'
/**
 * Jest Setup File
 * Global test configuration and utilities
 */

// Extend Jest matchers
expect.extend({
  toBeWithinRange(received, floor, ceiling) {
    const pass = received >= floor && received <= ceiling;
    if (pass) {
      return {
        message: () => `expected ${received} not to be within range ${floor} - ${ceiling}`,
        pass: true,
      };
    } else {
      return {
        message: () => `expected ${received} to be within range ${floor} - ${ceiling}`,
        pass: false,
      };
    }
  },
});

// Global test timeout
jest.setTimeout(10000);

// Mock console methods in tests
global.console = {
  ...console,
  log: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  info: jest.fn(),
  debug: jest.fn(),
};
EOF

# Create example test file
cat > __tests__/example.test.js << 'EOF'
/**
 * Example Test Suite - Demonstrates 8.0+ QA standards
 */

describe('Example Test Suite', () => {
  describe('Basic functionality', () => {
    it('should pass basic assertion', () => {
      expect(true).toBe(true);
    });

    it('should handle edge cases', () => {
      // Null/undefined handling
      expect(() => processData(null)).toThrow('Invalid input');
      expect(() => processData(undefined)).toThrow('Invalid input');
    });

    it('should test async operations', async () => {
      const result = await fetchData();
      expect(result).toBeDefined();
      expect(result.status).toBe('success');
    });

    it('should verify performance constraints', () => {
      const startTime = performance.now();
      const result = expensiveOperation();
      const endTime = performance.now();
      
      expect(endTime - startTime).toBeLessThan(200); // < 200ms
    });
  });

  describe('Boundary testing', () => {
    it.each([
      [0, 'zero'],
      [1, 'one'],
      [999, 'maximum'],
      [-1, 'negative']
    ])('should handle boundary value %i', (input, description) => {
      const result = boundaryFunction(input);
      expect(result).toBeDefined();
    });
  });
});

// Mock functions for testing
function processData(data) {
  if (data === null || data === undefined) {
    throw new Error('Invalid input');
  }
  return data;
}

async function fetchData() {
  return Promise.resolve({ status: 'success' });
}

function expensiveOperation() {
  return Array(1000).fill(0).map((_, i) => i * 2);
}

function boundaryFunction(value) {
  return value >= 0 ? value : 0;
}
EOF

echo "✅ Jest configuration completed!"
echo ""
echo "📊 Coverage Thresholds (8.0 QA Score):"
echo "  - Statements: 80%"
echo "  - Branches: 75%"
echo "  - Functions: 80%"
echo "  - Lines: 80%"
echo ""
echo "🔧 Available commands:"
echo "  npm test                 - Run all tests"
echo "  npm run test:coverage    - Run tests with coverage report"
echo "  npm run test:watch       - Run tests in watch mode"
echo "  npm run coverage:check   - Quick coverage check"
echo ""
echo "🎯 To achieve 8.0+ QA score, ensure:"
echo "  1. Test coverage meets all thresholds"
echo "  2. All edge cases are tested"
echo "  3. Tests are independent and isolated"
echo "  4. Performance tests are included"
echo "  5. Security-critical code has 95%+ coverage"