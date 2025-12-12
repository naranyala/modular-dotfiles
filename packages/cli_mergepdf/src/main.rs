use clap::Parser;
use colored::*;
use std::fs;
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use walkdir::WalkDir;

/// Merge every PDF found under a directory into per-folder files
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Root directory to scan recursively for PDF files
    dir: PathBuf,

    /// Skip auto-installation of qpdf
    #[arg(short = 'n', long = "no-install")]
    no_install: bool,

    /// Use alternative command (ghostscript) instead of qpdf
    #[arg(short = 'g', long = "gs")]
    use_ghostscript: bool,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();

    // Validate directory
    if !args.dir.exists() {
        eprintln!(
            "{}: Directory does not exist: {}",
            "Error".red(),
            args.dir.display()
        );
        std::process::exit(1);
    }

    if !args.dir.is_dir() {
        eprintln!(
            "{}: Path is not a directory: {}",
            "Error".red(),
            args.dir.display()
        );
        std::process::exit(1);
    }

    // Check which tool to use
    let tool = if args.use_ghostscript {
        // Check for ghostscript
        if !check_tool_installed("gs") {
            eprintln!(
                "{}: Ghostscript (gs) not found. Please install it with:",
                "Error".red()
            );
            eprintln!("    sudo dnf install ghostscript");
            std::process::exit(1);
        }
        "ghostscript"
    } else {
        // Check for qpdf
        if !check_tool_installed("qpdf") {
            if args.no_install {
                eprintln!("{}: qpdf is not installed. Install it with:", "Error".red());
                eprintln!("    sudo dnf install qpdf");
                eprintln!("Or run without --no-install flag to auto-install");
                std::process::exit(1);
            }

            println!(
                "{}: qpdf not found. Attempting to install...",
                "Note".yellow()
            );

            if !install_qpdf() {
                eprintln!(
                    "{}: Failed to install qpdf. Trying ghostscript instead...",
                    "Warning".yellow()
                );

                if check_tool_installed("gs") {
                    println!("{}: Using ghostscript as fallback", "Note".yellow());
                    "ghostscript"
                } else {
                    eprintln!("{}: Neither qpdf nor ghostscript available.", "Error".red());
                    eprintln!("Please install one of these tools:");
                    eprintln!("  sudo dnf install qpdf");
                    eprintln!("  sudo dnf install ghostscript");
                    std::process::exit(1);
                }
            } else {
                "qpdf"
            }
        } else {
            "qpdf"
        }
    };

    println!("{}: Using {} for PDF merging", "Info".cyan(), tool);

    // Collect PDF files
    let pdf_files = collect_pdfs(&args.dir);

    if pdf_files.is_empty() {
        println!("{}", "No PDF files found.".yellow());
        return Ok(());
    }

    println!("Found {} PDF file(s)", pdf_files.len());

    // Group by parent directory
    let mut buckets: std::collections::HashMap<PathBuf, Vec<PathBuf>> =
        std::collections::HashMap::new();

    for pdf in pdf_files {
        let parent = pdf.parent().unwrap_or(&args.dir).to_path_buf();
        buckets.entry(parent).or_default().push(pdf);
    }

    let mut total_merged = 0;

    // Process each directory
    for (dir, pdfs) in buckets {
        if pdfs.len() < 2 {
            if pdfs.len() == 1 {
                println!(
                    "{}: Skipping '{}' (only 1 PDF)",
                    "Note".yellow(),
                    dir.display()
                );
            }
            continue;
        }

        // Skip if output already exists
        let dir_name = dir
            .file_name()
            .unwrap_or_else(|| std::ffi::OsStr::new("merged"))
            .to_str()
            .unwrap_or("merged");

        let out_name = format!("{}_merged.pdf", dir_name);
        let out_path = dir.join(&out_name);

        // Skip if merged file already exists
        if out_path.exists() {
            println!(
                "{}: Output already exists: {}",
                "Skipping".yellow(),
                out_path.display()
            );
            continue;
        }

        println!(
            "\n{}: Merging {} PDF(s) in '{}'",
            "Processing".cyan(),
            pdfs.len(),
            dir.display()
        );

        let result = if tool == "qpdf" {
            merge_with_qpdf(&pdfs, &out_path)
        } else {
            merge_with_ghostscript(&pdfs, &out_path)
        };

        match result {
            Ok(_) => {
                println!("{} {}", "✓".green(), out_path.display());
                total_merged += 1;
            }
            Err(e) => {
                eprintln!(
                    "{}: Failed to merge PDFs in {}: {}",
                    "Error".red(),
                    dir.display(),
                    e
                );
            }
        }
    }

    if total_merged > 0 {
        println!(
            "\n{}",
            format!("Successfully created {} merged PDF file(s)", total_merged).green()
        );
    } else {
        println!(
            "\n{}",
            "No directories with multiple PDFs found to merge.".yellow()
        );
    }

    Ok(())
}

/// Check if a command-line tool is installed
fn check_tool_installed(tool: &str) -> bool {
    Command::new("which")
        .arg(tool)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|status| status.success())
        .unwrap_or(false)
}

/// Install qpdf on Fedora Linux
fn install_qpdf() -> bool {
    println!("Installing qpdf with sudo dnf...");

    let status = Command::new("sudo")
        .arg("dnf")
        .arg("install")
        .arg("-y")
        .arg("qpdf")
        .status();

    match status {
        Ok(exit_status) => exit_status.success(),
        Err(e) => {
            eprintln!("Failed to run dnf: {}", e);
            false
        }
    }
}

/// Collect PDF files recursively
fn collect_pdfs(root: &Path) -> Vec<PathBuf> {
    let mut pdfs = Vec::new();

    for entry in WalkDir::new(root)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file())
    {
        if let Some(ext) = entry.path().extension() {
            if ext.eq_ignore_ascii_case("pdf") {
                let file_name = entry.file_name().to_string_lossy();
                // Skip already merged files
                if !file_name.contains("_merged.pdf") && !file_name.ends_with("__merged.pdf") {
                    pdfs.push(entry.path().to_path_buf());
                }
            }
        }
    }

    // Sort for consistent ordering
    pdfs.sort();
    pdfs
}

/// Merge PDFs using qpdf
fn merge_with_qpdf(inputs: &[PathBuf], output: &Path) -> Result<(), Box<dyn std::error::Error>> {
    if inputs.is_empty() {
        return Err("No input PDFs provided".into());
    }

    // Build command arguments
    let mut cmd = Command::new("qpdf");
    cmd.arg("--empty"); // Start with empty PDF
    cmd.arg("--pages");

    // Add each input file
    for input in inputs {
        cmd.arg(input.to_str().unwrap());
        cmd.arg("1-z"); // All pages from the file
    }

    cmd.arg("--");
    cmd.arg(output);

    // Execute command
    let output = cmd.output()?;

    if !output.status.success() {
        let error_msg = String::from_utf8_lossy(&output.stderr);
        return Err(format!("qpdf failed: {}", error_msg).into());
    }

    Ok(())
}

/// Alternative: Merge PDFs using Ghostscript
fn merge_with_ghostscript(
    inputs: &[PathBuf],
    output: &Path,
) -> Result<(), Box<dyn std::error::Error>> {
    if inputs.is_empty() {
        return Err("No input PDFs provided".into());
    }

    // Convert paths to strings
    let input_strs: Vec<String> = inputs
        .iter()
        .map(|p| p.to_str().unwrap().to_string())
        .collect();

    // Create ghostscript command
    let mut cmd = Command::new("gs");

    cmd.args(&[
        "-dBATCH",
        "-dNOPAUSE",
        "-q",
        "-sDEVICE=pdfwrite",
        &format!("-sOutputFile={}", output.display()),
    ]);

    // Add input files
    for input in &input_strs {
        cmd.arg(input);
    }

    // Execute command
    let output_cmd = cmd.output()?;

    if !output_cmd.status.success() {
        let error_msg = String::from_utf8_lossy(&output_cmd.stderr);
        return Err(format!("ghostscript failed: {}", error_msg).into());
    }

    Ok(())
}

/// Display available tools
fn display_available_tools() {
    println!("Available PDF merging tools:");

    if check_tool_installed("qpdf") {
        println!("  ✓ qpdf");
    } else {
        println!("  ✗ qpdf (install with: sudo dnf install qpdf)");
    }

    if check_tool_installed("pdftk") {
        println!("  ✓ pdftk");
    } else {
        println!("  ✗ pdftk");
    }

    if check_tool_installed("gs") {
        println!("  ✓ ghostscript");
    } else {
        println!("  ✗ ghostscript (install with: sudo dnf install ghostscript)");
    }
}
