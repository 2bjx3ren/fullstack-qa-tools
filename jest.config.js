/**
 * Jest Configuration for QA 8.0+ Score Compliance
 * Aligned with v4.0 QA evaluation standards
 */

module.exports = {
  // Test environment
  testEnvironment: 'node',
  
  // Test file patterns
  testMatch: [
    '**/__tests__/**/*.{js,jsx,ts,tsx}',
    '**/*.{test,spec}.{js,jsx,ts,tsx}'
  ],
  
  // Coverage configuration - Aligned with 8.0 QA score requirements
  collectCoverage: true,
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.{js,ts}',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
    '!src/**/*.config.{js,ts}',
    '!src/**/node_modules/**'
  ],
  
  // Coverage thresholds - Must meet these for 8.0+ QA score
  coverageThreshold: {
    global: {
      statements: 80,    // 80% statement coverage (8.0 standard)
      branches: 75,      // 75% branch coverage (8.0 standard)
      functions: 80,     // 80% function coverage (8.0 standard)
      lines: 80         // 80% line coverage (8.0 standard)
    },
    // Critical paths require higher coverage
    './src/core/': {
      statements: 90,
      branches: 85,
      functions: 90,
      lines: 90
    },
    './src/security/': {
      statements: 95,    // Security code requires 95%+ coverage
      branches: 90,
      functions: 95,
      lines: 95
    }
  },
  
  // Performance settings for CI/CD
  maxWorkers: '50%',
  
  // Reporters for better visibility
  coverageReporters: [
    'text',
    'text-summary',
    'lcov',
    'html',
    'json-summary'
  ],
  
  // Setup files
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  
  // Transform files
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest'
  },
  
  // Module name mapper for imports
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@test/(.*)$': '<rootDir>/tests/$1'
  },
  
  // Ignore patterns
  testPathIgnorePatterns: [
    '/node_modules/',
    '/build/',
    '/dist/',
    '/.cache/'
  ],
  
  // Watch plugins for better DX
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname'
  ],
  
  // Fail fast in CI
  bail: process.env.CI === 'true' ? 1 : 0,
  
  // Verbose output in CI
  verbose: process.env.CI === 'true'
};