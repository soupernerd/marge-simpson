const fs = require('fs');
const path = require('path');

const htmlPath = path.join(__dirname, 'index.html');
const htmlContent = fs.readFileSync(htmlPath, 'utf8');

function test(description, fn) {
    try {
        fn();
        console.log(`✓ ${description}`);
        return true;
    } catch (error) {
        console.error(`✗ ${description}`);
        console.error(`  Error: ${error.message}`);
        return false;
    }
}

function assert(condition, message) {
    if (!condition) {
        throw new Error(message || 'Assertion failed');
    }
}

console.log('Running tests for index.html...\n');

let passed = 0;
let failed = 0;

// Test 1: File exists and is not empty
if (test('index.html exists and is not empty', () => {
    assert(htmlContent.length > 0, 'File should not be empty');
})) passed++; else failed++;

// Test 2: Has valid HTML structure
if (test('has valid HTML5 doctype', () => {
    assert(htmlContent.includes('<!DOCTYPE html>'), 'Should have HTML5 doctype');
})) passed++; else failed++;

// Test 3: Has html tag with lang attribute
if (test('has html tag with lang attribute', () => {
    assert(htmlContent.includes('<html lang="en">'), 'Should have html tag with lang attribute');
})) passed++; else failed++;

// Test 4: Has proper head section
if (test('has proper head section with charset and viewport', () => {
    assert(htmlContent.includes('<meta charset="UTF-8">'), 'Should have charset meta tag');
    assert(htmlContent.includes('viewport'), 'Should have viewport meta tag');
})) passed++; else failed++;

// Test 5: Has title related to flowers
if (test('has title related to flowers', () => {
    assert(htmlContent.toLowerCase().includes('<title>') &&
           htmlContent.toLowerCase().includes('flower'),
           'Should have a title containing "flower"');
})) passed++; else failed++;

// Test 6: Has heading with flowers theme
if (test('has heading with flowers theme', () => {
    assert(htmlContent.includes('<h1>') &&
           htmlContent.toLowerCase().includes('flower'),
           'Should have h1 heading about flowers');
})) passed++; else failed++;

// Test 7: Contains flower elements (emojis or CSS flowers)
if (test('contains flower elements', () => {
    const hasFlowerEmojis = /🌹|🌷|🌻|🌸|🌺|💐|🌼/.test(htmlContent);
    const hasFlowerClass = htmlContent.includes('class="flower');
    assert(hasFlowerEmojis || hasFlowerClass, 'Should contain flower emojis or flower CSS elements');
})) passed++; else failed++;

// Test 8: Has CSS styling
if (test('has CSS styling', () => {
    assert(htmlContent.includes('<style>'), 'Should have inline CSS styles');
})) passed++; else failed++;

// Test 9: Has garden container
if (test('has garden container element', () => {
    assert(htmlContent.includes('garden'), 'Should have a garden container');
})) passed++; else failed++;

// Test 10: Has multiple flower cards or elements
if (test('has multiple flower elements', () => {
    const flowerCardCount = (htmlContent.match(/flower-card/g) || []).length;
    const flowerClassCount = (htmlContent.match(/class="flower"/g) || []).length;
    assert(flowerCardCount >= 3 || flowerClassCount >= 3, 'Should have at least 3 flower elements');
})) passed++; else failed++;

// Test 11: Has animations
if (test('has CSS animations', () => {
    assert(htmlContent.includes('@keyframes'), 'Should have CSS keyframe animations');
    assert(htmlContent.includes('animation'), 'Should use animation property');
})) passed++; else failed++;

// Test 12: Has proper body closing tags
if (test('has proper closing tags', () => {
    assert(htmlContent.includes('</body>'), 'Should have closing body tag');
    assert(htmlContent.includes('</html>'), 'Should have closing html tag');
})) passed++; else failed++;

console.log(`\n${'='.repeat(40)}`);
console.log(`Tests: ${passed} passed, ${failed} failed`);
console.log(`${'='.repeat(40)}`);

process.exit(failed > 0 ? 1 : 0);
