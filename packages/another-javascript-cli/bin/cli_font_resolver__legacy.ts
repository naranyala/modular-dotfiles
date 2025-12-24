#!/usr/bin/env bun

import meow from 'meow';
import fs from 'fs-extra';
import path from 'path';
import { execSync } from 'child_process';

const cli = meow(`
  Fontsource Font Resolver
  ========================

  Downloads font files from Fontsource packages and copies them to a local directory.
  Fonts will be placed in: <output_path>/fonts/<font_name>/

  Usage
    $ font-resolver <font-name-or-url>

  Options
    --output, -o     Base output directory (default: .)
    --help, -h       Show this help message
    --version, -v    Show version

  Examples
    $ font-resolver open-sans
    $ font-resolver https://fontsource.org/fonts/noto-sans-mono -o ./public
    $ font-resolver roboto -o /absolute/path/to/assets
    $ font-resolver "noto-sans-jp" --output ../../shared
`, {
  importMeta: import.meta,
  flags: {
    output: {
      type: 'string',
      shortFlag: 'o',
      default: '.'
    }
  },
});

// Show help if no arguments provided
if (cli.input.length === 0) {
  cli.showHelp(0);
}

const [input] = cli.input;
const outputDirFlag = cli.flags.output;

/**
 * Extract font name from input (could be direct name or Fontsource URL)
 */
function extractFontName(input: string): string {
  // If it's a Fontsource URL
  if (input.startsWith('https://fontsource.org/fonts/')) {
    // Extract font name from URL path
    const url = new URL(input);
    const pathParts = url.pathname.split('/');
    
    // Find the font name part (usually after '/fonts/')
    const fontIndex = pathParts.indexOf('fonts') + 1;
    if (fontIndex > 0 && fontIndex < pathParts.length) {
      return pathParts[fontIndex];
    }
  }
  
  // If it's already just a font name, return it as-is
  return input;
}

/**
 * Normalize font name to Fontsource package convention (kebab-case)
 */
function normalizeFontName(fontName: string): string {
  return fontName
    .toLowerCase()
    // Replace any non-alphanumeric characters with hyphens
    .replace(/[^a-z0-9]/g, '-')
    // Replace multiple consecutive hyphens with a single one
    .replace(/-+/g, '-')
    // Remove leading/trailing hyphens
    .replace(/^-+|-+$/g, '');
}

/**
 * Get font output directory with strict format: <base_path>/fonts/<font_name>
 */
function getFontOutputDir(basePath: string, fontName: string): string {
  const resolvedBasePath = path.resolve(process.cwd(), basePath);
  return path.join(resolvedBasePath, 'fonts', fontName);
}

/**
 * List and summarize font files in a directory
 */
function listFontFiles(fontDir: string): void {
  const files = fs.readdirSync(fontDir);
  if (files.length === 0) return;
  
  console.log(`   Found ${files.length} font file(s)`);
  
  if (files.length <= 10) {
    files.forEach(file => console.log(`   • ${file}`));
  } else {
    console.log(`   • First 5 files: ${files.slice(0, 5).join(', ')}...`);
  }
  
  // Show font file summary
  const fileTypes = files.reduce((acc, file) => {
    const ext = path.extname(file).toLowerCase();
    acc[ext] = (acc[ext] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  
  console.log(`   File types: ${Object.entries(fileTypes).map(([ext, count]) => `${ext}(${count})`).join(', ')}`);
}

/**
 * Clean up installed package from node_modules
 */
function cleanupPackage(packageName: string): void {
  const nodeModulesPath = path.join(process.cwd(), 'node_modules', packageName);
  if (fs.existsSync(nodeModulesPath)) {
    fs.removeSync(nodeModulesPath);
    console.log('🧹 Cleaned up node_modules.');
  }
}

// Extract and normalize the font name
const extractedFontName = extractFontName(input);
const normalizedFont = normalizeFontName(extractedFontName);

if (!normalizedFont) {
  console.error('Error: Could not extract valid font name from input.');
  process.exit(1);
}

const packageName = `@fontsource/${normalizedFont}`;
const fontOutputDir = getFontOutputDir(outputDirFlag, normalizedFont);

console.log(`🔍 Input: ${input}`);
console.log(`📝 Extracted font: ${extractedFontName}`);
console.log(`🔧 Normalized: ${normalizedFont}`);
console.log(`📦 Package: ${packageName}`);
console.log(`📁 Base output: ${outputDirFlag}`);
console.log(`📂 Font output: ${fontOutputDir}`);

try {
  // Step 1: Install the package
  console.log('\n📦 Installing Fontsource package...');
  execSync(`bun add ${packageName}`, { stdio: 'inherit' });

  // Step 2: Locate the package in node_modules
  const nodeModulesPath = path.join(process.cwd(), 'node_modules', packageName);
  const filesDir = path.join(nodeModulesPath, 'files');
  
  if (!fs.existsSync(filesDir)) {
    throw new Error(`Font files not found in ${filesDir}. Check if the package exists.`);
  }

  // Step 3: Create output directory with strict format
  console.log(`📋 Creating output directory...`);
  fs.ensureDirSync(fontOutputDir);

  // Step 4: Copy all font files
  console.log(`📋 Copying font files...`);
  fs.copySync(filesDir, fontOutputDir);
  console.log(`✅ Fonts copied to: ${fontOutputDir}`);
  
  // Step 5: List files
  listFontFiles(fontOutputDir);

  // Step 6: Cleanup
  cleanupPackage(packageName);

  // Show relative path for easier reference
  const relativePath = path.relative(process.cwd(), fontOutputDir);
  console.log(`\n📂 Fonts available at: ./${relativePath}`);

  // Show example of how to reference the fonts
  console.log(`\n💡 To reference these fonts in CSS, use:`);
  console.log(`   url("./${relativePath}/[font-file.woff2]")`);

} catch (error) {
  console.error(`\n❌ Error: ${error.message}`);
  
  // Cleanup on error
  try {
    cleanupPackage(packageName);
  } catch (cleanupError) {
    console.log('⚠️ Could not clean up node_modules.');
  }
  
  process.exit(1);
}
