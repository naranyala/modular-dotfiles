use clap::Parser;
use std::path::{Path, PathBuf};
use anyhow::{Result, bail, Context};
use walkdir::WalkDir;
use colored::*;

#[derive(Parser)]
#[command(name = "md2pdf")]
#[command(about = "🚀 Convert Markdown → Beautiful PDF (powered by Typst)")]
#[command(version, long_about = None)]
struct Cli {
    /// Input: markdown file or directory
    path: PathBuf,

    /// Output directory (defaults to same as input)
    #[arg(short, long)]
    output: Option<PathBuf>,

    /// Overwrite existing PDFs
    #[arg(short, long)]
    force: bool,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    let path = cli
        .path
        .canonicalize()
        .with_context(|| format!("Failed to canonicalize path: {}", cli.path.display()))?;

    if path.is_file() {
        convert_file(&path, &cli.output, cli.force)?;
    } else if path.is_dir() {
        convert_directory(&path, &cli.output, cli.force)?;
    } else {
        bail!("Path does not exist or is not accessible: {}", path.display());
    }

    Ok(())
}

fn convert_file(input: &Path, output_dir: &Option<PathBuf>, force: bool) -> Result<()> {
    let output = get_output_path(input, output_dir);

    if output.exists() && !force {
        println!("{} {} (use -f to overwrite)", "Skipping".yellow(), output.display());
        return Ok(());
    }

    run_typst(input, &output)?;
    println!("{} {} → {}", "✓".green(), input.display(), output.display());
    Ok(())
}

fn convert_directory(dir: &Path, output_dir: &Option<PathBuf>, force: bool) -> Result<()> {
    let mut converted = 0;
    let mut skipped = 0;

    for entry in WalkDir::new(dir)
        .max_depth(1)
        .into_iter()
        .filter_map(|e| e.ok())
    {
        let path = entry.path();
        if path.is_file() {
            if let Some(ext) = path.extension().and_then(|s| s.to_str()) {
                if ext == "md" {
                    // Skip hidden files (starting with .) and temporary files (e.g., foo.md~)
                    if let Some(name) = path.file_name().and_then(|s| s.to_str()) {
                        if name.starts_with('.') || name.contains('~') {
                            continue;
                        }
                    } else {
                        // Filename not valid UTF-8 — skip
                        eprintln!("{} Skipping file with non-UTF-8 name: {:?}", "⚠".yellow(), path);
                        continue;
                    }

                    match convert_process_file(path, output_dir, force) {
                        Ok(()) => converted += 1,
                        Err(e) => eprintln!("{} Failed {}: {}", "✗".red(), path.display(), e),
                    }
                }
            }
        }
    }

    if converted > 0 {
        println!("\n{} Successfully converted {} file(s) in {}", "🎉".cyan(), converted, dir.display());
    } else {
        println!("{} No markdown files found in {}", "ℹ".blue(), dir.display());
    }

    Ok(())
}

// Helper to wrap convert_file with error context
fn convert_process_file(path: &Path, output_dir: &Option<PathBuf>, force: bool) -> Result<()> {
    convert_file(path, output_dir, force)
        .with_context(|| format!("Failed to process file: {}", path.display()))
}

fn get_output_path(input: &Path, output_dir: &Option<PathBuf>) -> PathBuf {
    let stem = input.file_stem().unwrap_or_else(|| std::ffi::OsStr::new("output"));
    let pdf_name = format!("{}.pdf", stem.to_string_lossy());
    match output_dir {
        Some(dir) => dir.join(pdf_name),
        None => input.with_file_name(pdf_name),
    }
}

fn run_typst(input: &Path, output: &Path) -> Result<()> {
    let input_str = input
        .to_str()
        .ok_or_else(|| anyhow::anyhow!("Input path is not valid UTF-8: {:?}", input))?;
    let output_str = output
        .to_str()
        .ok_or_else(|| anyhow::anyhow!("Output path is not valid UTF-8: {:?}", output))?;

    let status = std::process::Command::new("typst")
        .args(["compile", input_str, output_str])
        .status()
        .with_context(|| "Failed to execute 'typst' command. Is Typst installed and in PATH?")?;

    if !status.success() {
        bail!("Typst failed to compile {}", input.display());
    }
    Ok(())
}
