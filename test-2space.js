#!/usr/bin/env node

/**
 * Test suite for 2space.html
 * Tests the structure and functionality of the interactive space view
 */

const fs = require('fs');
const path = require('path');

let passed = 0;
let failed = 0;

function test(name, condition) {
    if (condition) {
        console.log(`✅ PASS: ${name}`);
        passed++;
    } else {
        console.log(`❌ FAIL: ${name}`);
        failed++;
    }
}

function runTests() {
    console.log('🚀 Running 2space.html Test Suite\n');
    console.log('='.repeat(50));

    // Read the HTML file
    const htmlPath = path.join(__dirname, '2space.html');
    let html;
    try {
        html = fs.readFileSync(htmlPath, 'utf8');
    } catch (e) {
        console.error('❌ FATAL: Could not read 2space.html');
        process.exit(1);
    }

    // Structure tests
    console.log('\n📋 Structure Tests:\n');

    test('HTML file exists and is readable', html.length > 0);
    test('Has DOCTYPE declaration', html.includes('<!DOCTYPE html>'));
    test('Has html lang attribute', html.includes('<html lang="en">'));
    test('Has meta charset UTF-8', html.includes('charset="UTF-8"'));
    test('Has viewport meta tag', html.includes('viewport'));
    test('Has title element', html.includes('<title>'));

    // Canvas tests
    console.log('\n🎨 Canvas Tests:\n');

    test('Has canvas element', html.includes('<canvas'));
    test('Canvas has id="space-canvas"', html.includes('id="space-canvas"'));
    test('Gets 2D context', html.includes("getContext('2d')"));

    // Interactive element tests
    console.log('\n🎮 Interactive Element Tests:\n');

    test('Has nebula toggle button', html.includes('btn-nebula'));
    test('Has shooting star button', html.includes('btn-shooting'));
    test('Has warp button', html.includes('btn-warp'));
    test('Has reset button', html.includes('btn-reset'));
    test('Has info panel', html.includes('info-panel'));
    test('Has info title element', html.includes('info-title'));
    test('Has info description element', html.includes('info-description'));

    // Display tests
    console.log('\n📊 Display Tests:\n');

    test('Has coordinate display', html.includes('coord-display'));
    test('Has zoom display', html.includes('zoom-display'));
    test('Has object count display', html.includes('object-count'));
    test('Has instructions section', html.includes('class="instructions"'));

    // CSS tests
    console.log('\n🎨 CSS Tests:\n');

    test('Has style tag', html.includes('<style>'));
    test('Has control button styles', html.includes('.control-btn'));
    test('Has info panel styles', html.includes('.info-panel'));
    test('Has twinkle animation', html.includes('@keyframes twinkle'));
    test('Has fadeIn animation', html.includes('@keyframes fadeIn'));
    test('Has fadeOut animation', html.includes('@keyframes fadeOut'));

    // JavaScript function tests
    console.log('\n⚡ JavaScript Function Tests:\n');

    test('Has init function', html.includes('function init()'));
    test('Has resize function', html.includes('function resize()'));
    test('Has generateStars function', html.includes('function generateStars'));
    test('Has generatePlanets function', html.includes('function generatePlanets'));
    test('Has generateNebulaParticles function', html.includes('function generateNebulaParticles'));
    test('Has animate function', html.includes('function animate()'));
    test('Has drawStars function', html.includes('function drawStars'));
    test('Has drawPlanets function', html.includes('function drawPlanets'));
    test('Has drawNebula function', html.includes('function drawNebula'));
    test('Has drawShootingStars function', html.includes('function drawShootingStars'));
    test('Has drawWarpEffect function', html.includes('function drawWarpEffect'));
    test('Has toggleNebula function', html.includes('function toggleNebula()'));
    test('Has triggerShootingStar function', html.includes('function triggerShootingStar()'));
    test('Has toggleWarp function', html.includes('function toggleWarp()'));
    test('Has resetView function', html.includes('function resetView()'));
    test('Has showInfoPanel function', html.includes('function showInfoPanel'));
    test('Has closeInfoPanel function', html.includes('function closeInfoPanel()'));
    test('Has lightenColor helper', html.includes('function lightenColor'));
    test('Has darkenColor helper', html.includes('function darkenColor'));

    // Event listener tests
    console.log('\n🖱️ Event Listener Tests:\n');

    test('Has mousedown listener', html.includes("addEventListener('mousedown'"));
    test('Has mousemove listener', html.includes("addEventListener('mousemove'"));
    test('Has mouseup listener', html.includes("addEventListener('mouseup'"));
    test('Has click listener', html.includes("addEventListener('click'"));
    test('Has wheel listener (zoom)', html.includes("addEventListener('wheel'"));
    test('Has resize listener', html.includes("addEventListener('resize'"));
    test('Has keydown listener', html.includes("addEventListener('keydown'"));
    test('Has touch support (touchstart)', html.includes("addEventListener('touchstart'"));
    test('Has touch support (touchmove)', html.includes("addEventListener('touchmove'"));
    test('Has touch support (touchend)', html.includes("addEventListener('touchend'"));

    // Data structure tests
    console.log('\n📦 Data Structure Tests:\n');

    test('Has planetTypes array', html.includes('const planetTypes'));
    test('Has starTypes array', html.includes('const starTypes'));
    test('Has stars array', html.includes('let stars = []'));
    test('Has planets array', html.includes('let planets = []'));
    test('Has shootingStars array', html.includes('let shootingStars = []'));
    test('Has nebulaParticles array', html.includes('let nebulaParticles = []'));

    // Feature tests
    console.log('\n✨ Feature Tests:\n');

    test('Has dragging functionality', html.includes('isDragging'));
    test('Has zoom functionality', html.includes('zoom'));
    test('Has offset tracking', html.includes('offsetX') && html.includes('offsetY'));
    test('Has warp mode', html.includes('warpMode'));
    test('Has nebula toggle', html.includes('showNebula'));
    test('Planets have rings property', html.includes('hasRings'));
    test('Planets have moon property', html.includes('hasMoon'));
    test('Stars have twinkle effect', html.includes('twinkleOffset'));
    test('Has keyboard shortcuts', html.includes("case 'n':") && html.includes("case 's':") && html.includes("case 'w':"));

    // Planet data validation
    console.log('\n🪐 Planet Data Tests:\n');

    test('Has Terra Nova planet', html.includes('Terra Nova'));
    test('Has Crimson Giant planet', html.includes('Crimson Giant'));
    test('Has Emerald Prime planet', html.includes('Emerald Prime'));
    test('Has Frozen Sentinel planet', html.includes('Frozen Sentinel'));
    test('Has Golden Dunes planet', html.includes('Golden Dunes'));
    test('Has Violet Storm planet', html.includes('Violet Storm'));
    test('Has Azure Ring planet', html.includes('Azure Ring'));
    test('Has Obsidian Core planet', html.includes('Obsidian Core'));
    test('Planets have descriptions', html.includes('description:'));

    // Summary
    console.log('\n' + '='.repeat(50));
    console.log('\n📊 Test Summary:\n');
    console.log(`   Total: ${passed + failed}`);
    console.log(`   Passed: ${passed}`);
    console.log(`   Failed: ${failed}`);
    console.log(`   Status: ${failed === 0 ? '✅ All tests passed!' : '❌ Some tests failed'}`);
    console.log('\n' + '='.repeat(50));

    process.exit(failed > 0 ? 1 : 0);
}

runTests();
