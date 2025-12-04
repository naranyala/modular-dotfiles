#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>   // for chdir(), getcwd()
#include <limits.h>   // for PATH_MAX

#define MAX_PATHS 100
#define MAX_LEN PATH_MAX

// Resolve store file location
const char* get_store_file() {
    static char path[PATH_MAX];
    const char *custom = getenv("DIRCLI_STORE");
    if (custom) return custom;

    const char *home = getenv("HOME");
    if (!home) home = getenv("USERPROFILE"); // Windows fallback
    snprintf(path, sizeof(path), "%s/.dircli_store", home);
    return path;
}

// Load paths from file
int load_paths(char dir_store[MAX_PATHS][MAX_LEN]) {
    FILE *f = fopen(get_store_file(), "r");
    if (!f) return 0;
    int count = 0;
    while (count < MAX_PATHS && fgets(dir_store[count], MAX_LEN, f)) {
        dir_store[count][strcspn(dir_store[count], "\n")] = 0; // strip newline
        count++;
    }
    fclose(f);
    return count;
}

// Save paths to file
void save_paths(char dir_store[MAX_PATHS][MAX_LEN], int dir_count) {
    FILE *f = fopen(get_store_file(), "w");
    if (!f) {
        perror("Failed to save store");
        return;
    }
    for (int i = 0; i < dir_count; i++) {
        fprintf(f, "%s\n", dir_store[i]);
    }
    fclose(f);
}

// Add path
void add_path(char dir_store[MAX_PATHS][MAX_LEN], int *dir_count, const char *path) {
    if (*dir_count < MAX_PATHS) {
        strncpy(dir_store[*dir_count], path, MAX_LEN - 1);
        dir_store[*dir_count][MAX_LEN - 1] = '\0';
        (*dir_count)++;
        save_paths(dir_store, *dir_count);
        printf("✅ Path added: %s\n", path);
    } else {
        printf("❌ Store is full!\n");
    }
}

// List paths
void list_paths(char dir_store[MAX_PATHS][MAX_LEN], int dir_count) {
    if (dir_count == 0) {
        printf("No paths stored yet.\n");
        return;
    }
    printf("📂 Stored paths:\n");
    for (int i = 0; i < dir_count; i++) {
        printf("[%d] %s\n", i, dir_store[i]);
    }
}

// Remove path
void remove_path(char dir_store[MAX_PATHS][MAX_LEN], int *dir_count, int index) {
    if (index < 0 || index >= *dir_count) {
        printf("❌ Invalid index!\n");
        return;
    }
    printf("🗑️ Removing: %s\n", dir_store[index]);
    for (int i = index; i < *dir_count - 1; i++) {
        strncpy(dir_store[i], dir_store[i + 1], MAX_LEN);
    }
    (*dir_count)--;
    save_paths(dir_store, *dir_count);
}

// Navigate (print path for shell to use)
void navigate(char dir_store[MAX_PATHS][MAX_LEN], int dir_count, int index) {
    if (index < 0 || index >= dir_count) {
        fprintf(stderr, "❌ Invalid index!\n");
        return;
    }
    // Print the path so user can do: cd $(dircli --nav <index>)
    printf("%s\n", dir_store[index]);
}

// Search
void search_paths(char dir_store[MAX_PATHS][MAX_LEN], int dir_count, const char *keyword) {
    int found = 0;
    for (int i = 0; i < dir_count; i++) {
        if (strstr(dir_store[i], keyword) != NULL) {
            printf("[%d] %s\n", i, dir_store[i]);
            found = 1;
        }
    }
    if (!found) {
        printf("🔍 No match found for '%s'\n", keyword);
    }
}

// Help
void print_help() {
    printf("Usage: dircli [command] [options]\n");
    printf("Commands:\n");
    printf("  --add <path>       Add a directory path\n");
    printf("  --list             List stored paths\n");
    printf("  --rm <index>       Remove path at index\n");
    printf("  --nav <index>      Print path at index (use with cd)\n");
    printf("  --search <keyword> Search paths by keyword\n");
    printf("  --help             Show this help message\n");
}

int main(int argc, char *argv[]) {
    char dir_store[MAX_PATHS][MAX_LEN];
    int dir_count = load_paths(dir_store);

    if (argc < 2) {
        print_help();
        return 1;
    }

    if (strcmp(argv[1], "--help") == 0) {
        print_help();
    } else if (strcmp(argv[1], "--add") == 0 && argc >= 3) {
        add_path(dir_store, &dir_count, argv[2]);
    } else if (strcmp(argv[1], "--list") == 0) {
        list_paths(dir_store, dir_count);
    } else if (strcmp(argv[1], "--rm") == 0 && argc >= 3) {
        remove_path(dir_store, &dir_count, atoi(argv[2]));
    } else if (strcmp(argv[1], "--nav") == 0 && argc >= 3) {
        navigate(dir_store, dir_count, atoi(argv[2]));
    } else if (strcmp(argv[1], "--search") == 0 && argc >= 3) {
        search_paths(dir_store, dir_count, argv[2]);
    } else {
        printf("❌ Unknown command\n");
        print_help();
    }

    return 0;
}

