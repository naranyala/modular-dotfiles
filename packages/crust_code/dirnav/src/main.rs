// src/main.rs
use anyhow::{Context, Result};
use colored::*;
use serde::{Deserialize, Serialize};
use std::env;
use std::fs;
// use std::io::{self, Write};
use std::path::{Path, PathBuf};

#[cfg(windows)]
use winapi::shared::minwindef::MAX_PATH;
#[cfg(windows)]
use winapi::um::shlobj::{SHGetFolderPathA, CSIDL_PROFILE};
#[cfg(windows)]
// use winapi::um::winnt::HRESULT;
#[cfg(windows)]
use windows::Win32::Foundation::S_OK;

const MAX_PATHS: usize = 100;

#[derive(Debug, Serialize, Deserialize, Clone)]
struct DirStore {
    paths: Vec<String>,
}

impl DirStore {
    fn new() -> Self {
        Self {
            paths: Vec::with_capacity(MAX_PATHS),
        }
    }

    fn load() -> Result<Self> {
        let store_file = get_store_file()?;
        if store_file.exists() {
            let content = fs::read_to_string(&store_file)
                .with_context(|| format!("Failed to read store file: {:?}", store_file))?;
            let store: DirStore =
                serde_json::from_str(&content).with_context(|| "Failed to parse store file")?;
            Ok(store)
        } else {
            Ok(Self::new())
        }
    }

    fn save(&self) -> Result<()> {
        let store_file = get_store_file()?;
        if let Some(parent) = store_file.parent() {
            fs::create_dir_all(parent)
                .with_context(|| format!("Failed to create directory: {:?}", parent))?;
        }

        let json =
            serde_json::to_string_pretty(self).with_context(|| "Failed to serialize store")?;
        fs::write(&store_file, json)
            .with_context(|| format!("Failed to write store file: {:?}", store_file))?;
        Ok(())
    }

    fn add_path(&mut self, path: &str) -> Result<()> {
        if self.paths.len() >= MAX_PATHS {
            anyhow::bail!("Store is full!");
        }

        let path = normalize_path(path);

        // Validate path exists
        if !Path::new(&path).exists() {
            eprintln!("⚠️  Warning: Path doesn't exist: {}", path);
        }

        self.paths.push(path.clone());
        self.save()?;
        println!("{} Path added: {}", "✅".green(), path.cyan());
        Ok(())
    }

    fn list_paths(&self) {
        if self.paths.is_empty() {
            println!("No paths stored yet.");
            return;
        }

        println!("{} Stored paths:", "📂".blue());
        for (i, path) in self.paths.iter().enumerate() {
            println!("{} {}", format!("[{}]", i).yellow(), path);
        }
    }

    fn remove_path(&mut self, index: usize) -> Result<()> {
        if index >= self.paths.len() {
            anyhow::bail!("Invalid index!");
        }

        let removed = self.paths.remove(index);
        self.save()?;
        println!("{} Removing: {}", "🗑️".red(), removed);
        Ok(())
    }

    fn navigate(&self, index: usize) -> Result<()> {
        if index >= self.paths.len() {
            anyhow::bail!("Invalid index!");
        }

        println!("{}", self.paths[index]);
        Ok(())
    }

    fn search_paths(&self, keyword: &str) {
        let keyword = keyword.to_lowercase();
        let mut found = false;

        for (i, path) in self.paths.iter().enumerate() {
            if path.to_lowercase().contains(&keyword) {
                println!("{} {}", format!("[{}]", i).yellow(), path);
                found = true;
            }
        }

        if !found {
            println!("{} No match found for '{}'", "🔍".yellow(), keyword);
        }
    }
}

fn normalize_path(path: &str) -> String {
    #[cfg(windows)]
    {
        path.replace('/', "\\")
    }
    #[cfg(not(windows))]
    {
        path.replace('\\', "/")
    }
}

#[cfg(windows)]
fn get_home_dir() -> Result<PathBuf> {
    use std::ptr;

    unsafe {
        let mut path = vec![0u8; MAX_PATH as usize];
        let result = SHGetFolderPathA(
            ptr::null_mut(),
            CSIDL_PROFILE,
            ptr::null_mut(),
            0,
            path.as_mut_ptr() as *mut i8,
        );

        if result == S_OK.0 {
            let len = path.iter().position(|&b| b == 0).unwrap_or(0);
            let path_str = String::from_utf8_lossy(&path[..len]);
            Ok(PathBuf::from(path_str.to_string()))
        } else {
            // Fallback to environment variables
            if let Ok(userprofile) = env::var("USERPROFILE") {
                Ok(PathBuf::from(userprofile))
            } else if let Ok(homedrive) = env::var("HOMEDRIVE") {
                if let Ok(homepath) = env::var("HOMEPATH") {
                    Ok(PathBuf::from(format!("{}{}", homedrive, homepath)))
                } else {
                    Ok(PathBuf::from("C:\\"))
                }
            } else {
                Ok(PathBuf::from("C:\\"))
            }
        }
    }
}

#[cfg(not(windows))]
fn get_home_dir() -> Result<PathBuf> {
    dirs::home_dir().with_context(|| "Failed to get home directory")
}

fn get_store_file() -> Result<PathBuf> {
    if let Ok(custom) = env::var("DIRCLI_STORE") {
        return Ok(PathBuf::from(custom));
    }

    let home = get_home_dir()?;
    Ok(home.join(".dircli_store.json"))
}

fn print_help() {
    println!("Usage: dirnav [command] [options]");
    println!("Commands:");
    println!("  --add <path>       Add a directory path");
    println!("  --list             List stored paths");
    println!("  --rm <index>       Remove path at index");
    println!("  --nav <index>      Print path at index (use with cd)");
    println!("  --search <keyword> Search paths by keyword");
    println!("  --help             Show this help message");
    println!("\nEnvironment variables:");
    println!("  DIRCLI_STORE       Custom store file location");
}

fn main() -> Result<()> {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        print_help();
        return Ok(());
    }

    let mut store = DirStore::load()?;

    match args[1].as_str() {
        "--help" => print_help(),
        "--add" => {
            if args.len() < 3 {
                eprintln!("❌ Missing path argument");
                return Ok(());
            }
            store.add_path(&args[2])?;
        }
        "--list" => store.list_paths(),
        "--rm" => {
            if args.len() < 3 {
                eprintln!("❌ Missing index argument");
                return Ok(());
            }
            let index: usize = args[2].parse().with_context(|| "Invalid index")?;
            store.remove_path(index)?;
        }
        "--nav" => {
            if args.len() < 3 {
                eprintln!("❌ Missing index argument");
                return Ok(());
            }
            let index: usize = args[2].parse().with_context(|| "Invalid index")?;
            store.navigate(index)?;
        }
        "--search" => {
            if args.len() < 3 {
                eprintln!("❌ Missing keyword argument");
                return Ok(());
            }
            store.search_paths(&args[2]);
        }
        _ => {
            eprintln!("❌ Unknown command");
            print_help();
        }
    }

    Ok(())
}
