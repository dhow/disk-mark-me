# disk-mark-me - CrystalDiskMark-alike disk benchmark on Linux & macOS (Beta)

`disk-mark-me` is a shell script that presents disk benchmark results in a format similar to CrystalDiskMark's default profile, by leveraging `fio` (Flexible I/O Tester). It is designed for Linux-based systems, including embedded devices like handheld gaming consoles running JELOS or ROCKNIX, and standard distributions like Debian/Ubuntu. It now also includes **beta support for macOS**.

## Example Output (Non-Verbose, v1.2.0 - defaults used)

```
------------------------------------------------------------------------------
disk-mark-me v1.2.0 - fio v3.40 
------------------------------------------------------------------------------
* MB/s = 1,000,000 bytes/s
* Target: . | Test File Size: 1g (IEC) | Rounds: 5 | OS: Darwin

[Read]
  SEQ   1MiB (Q= 8, T=1) : 5913.200 MB/s [ 5638.8 IOPS]
  SEQ   1MiB (Q= 1, T=1) : 1707.400 MB/s [ 1627.6 IOPS]
  RND   4KiB (Q=32, T=1) :  142.000 MB/s [ 34640.0 IOPS]
  RND   4KiB (Q= 1, T=1) :   37.860 MB/s [ 9242.8 IOPS]

[Write]
  SEQ   1MiB (Q= 8, T=1) : 6948.600 MB/s [ 6626.2 IOPS]
  SEQ   1MiB (Q= 1, T=1) : 4177.800 MB/s [ 3983.6 IOPS]
  RND   4KiB (Q=32, T=1) :   86.740 MB/s [ 21160.0 IOPS]
  RND   4KiB (Q= 1, T=1) :   28.260 MB/s [ 6899.2 IOPS]

Benchmark complete.
```

## Features

*   Tests sequential and random read/write performance.
*   Mimics CrystalDiskMark's default test configurations (Block Size, Queue Depth, Threads).
*   Calculates and displays results in MB/s and IOPS.
*   Compatible with Linux and macOS (macOS support is beta).
*   Allows customization of:
    *   Target directory for the benchmark.
    *   Test file size.
    *   Number of rounds per test configuration (results are averaged).
    *   Specific benchmark types to run (read, write, or both).
*   Verbose mode for detailed per-round output and informational messages.
*   Pre-run checks for required tools and sufficient disk space.
*   Clears disk caches before read tests for more accurate results (if permissions allow; uses OS-specific methods).

## Benchmark Profile

The script runs the following test configurations, mirroring CrystalDiskMark's default:

| Type | Block Size | Queues | Threads |
| :--- | :--------- | :----- | :------ |
| SEQ  | 1 MiB      | 8      | 1       |
| SEQ  | 1 MiB      | 1      | 1       |
| RND  | 4 KiB      | 32     | 1       |
| RND  | 4 KiB      | 1      | 1       |

By default, both Read and Write operations are tested for each configuration. This can be controlled using the `-b` option.

## Prerequisites

The script requires the following command-line tools to be installed and accessible in your system's `PATH`:

*   `fio`: The core I/O benchmarking engine.
*   `numfmt`: For number formatting (part of GNU Coreutils).
*   Standard utilities: `grep` (with PCRE/-P support), `awk`, `bc`, `df`, `stat`, `id`, `touch`, and `rm`. These are usually present on most Linux and macOS systems, but the script will check for them and list any missing ones. If `grep -P` fails, ensure you have GNU grep installed and in your PATH.

`sudo` is optional but recommended if you want the script to attempt clearing disk caches before read tests (requires appropriate sudo permissions without a password prompt for the cache-clearing commands, or running the script as root).

### OS-Specific Prerequisites & Installation

**Linux**

*   **Debian / Ubuntu / similar distributions:**
    Most prerequisites are typically pre-installed. You mainly need to install `fio` and ensure `coreutils` (which provides `numfmt`) is present.
    ```bash
    sudo apt update
    sudo apt install fio coreutils
    ```
    If `bc` or `gawk` (GNU awk) are reported missing by the script, install them: `sudo apt install bc gawk`.

*   **JELOS / ROCKNIX (with Entware):**
    1.  **Install Entware (if not already installed):**
        Log in to your device via SSH and run the official Entware installer:
        ```bash
        /usr/sbin/installentware
        ```
        Follow the on-screen prompts. It may ask to reboot. Entware setup typically handles adding `/opt/bin` and `/opt/sbin` to your `PATH`.

    2.  **Install Required Packages via opkg:**
        After Entware is set up, use `opkg` to install the necessary tools:
        ```bash
        opkg update
        opkg install fio coreutils coreutils-numfmt
        ```
        *   `fio`: The core benchmarking tool.
        *   `coreutils`: Provides Entware's versions of `df`, `stat`, `numfmt` (via `coreutils-numfmt`), `id`, `touch`, `rm`.
        *   `coreutils-numfmt`: Ensures `numfmt` is available.
        *   The script also relies on `bc`, `grep`, and `awk`. These are typically present. If the script reports them as missing, install them via `opkg install bc gawk grep`.

    3.  **Verify Tools (JELOS/ROCKNIX):**
        ```bash
        which fio numfmt
        ```
        They should typically point to paths within `/opt/bin/`.

**macOS (Beta Support):**

1.  **Install Homebrew (if not already installed):**
    Follow the instructions at [https://brew.sh](https://brew.sh).

2.  **Install Required Packages via Homebrew:**
    ```bash
    brew install fio coreutils
    ```
    *   `fio`: The core benchmarking tool.
    *   `coreutils`: Provides GNU `numfmt` and other GNU utilities. Homebrew typically makes these available in your `PATH` without a `g` prefix if they don't conflict with system utilities, or provides instructions on how to add them if they are prefixed.
    *   `bc`, `grep`, and `awk` are typically available by default on macOS. If `grep -P` functionality is missing (macOS default `grep` lacks `-P`), `brew install grep` will provide GNU grep. Homebrew usually makes this available as `ggrep` or handles PATH adjustments; ensure `grep -P` works or that GNU `grep` is prioritized in your PATH.

3.  **Verify Tools (macOS):**
    ```bash
    which fio numfmt grep
    ```
    Ensure these point to the versions installed by Homebrew (usually in `/usr/local/bin` or `/opt/homebrew/bin`).

## Installation (Script Itself)

The recommended way to install `disk-mark-me` is by using the provided `Makefile`, which handles copying the script to a suitable location and making it executable.

1.  **Get the Script and Makefile:**
    *   **Option A: Clone the repository (recommended if you have `git`):**
        ```bash
        git clone https://github.com/dhow/disk-mark-me.git
        cd disk-mark-me
        ```
    *   **Option B: Download a ZIP archive:**
        Go to the repository page (e.g., `https://github.com/dhow/disk-mark-me`), click on "Code", then "Download ZIP". Extract the ZIP file and navigate into the `disk-mark-me-main` (or similar) directory.
    *   **Option C: Download individual files (if only needing the script and Makefile manually):**
        ```bash
        # Replace with your actual raw file URLs
        curl -LO https://raw.githubusercontent.com/dhow/disk-mark-me/main/disk-mark-me
        curl -LO https://raw.githubusercontent.com/dhow/disk-mark-me/main/Makefile
        chmod +x disk-mark-me # Make the script executable
        ```

2.  **Install using `make`:**
    Once you have the `disk-mark-me` script and `Makefile` in your current directory:
    *   **User-local installation (default, to `~/.local/bin`):**
        ```bash
        make install
        ```
        This will copy `disk-mark-me` to `~/.local/bin/disk-mark-me` and make it executable.
        *Ensure `~/.local/bin` is in your `PATH`.*

    *   **System-wide installation (e.g., to `/usr/local/bin`):**
        ```bash
        sudo make PREFIX=/usr/local install
        ```
        This typically requires `sudo` privileges.

3.  **Update:**
    If you've updated your local repository (e.g., via `git pull`) or downloaded newer versions of the script and Makefile:
    ```bash
    make update # For user-local
    # or
    sudo make PREFIX=/usr/local update # For system-wide, if installed there
    ```
    This is an alias for `make install` and will overwrite the existing installed script with the new version.

4.  **Uninstall:**
    *   **From user-local installation:**
        ```bash
        make uninstall
        ```
    *   **From system-wide installation:**
        ```bash
        sudo make PREFIX=/usr/local uninstall
        ```
    *Important: You must use the same `PREFIX` for uninstalling as you did for installing.*

5.  **View Makefile Help & Options:**
    ```bash
    make help
    ```
    This will show available `make` targets and current paths.

**After Installation:**

*   Ensure the installation directory (e.g., `~/.local/bin` or `/usr/local/bin`) is included in your system's `PATH` environment variable.
*   You may need to start a new shell session or `source` your shell's profile file (e.g., `~/.bashrc`, `~/.zshrc`, `~/.profile`) for the command to be recognized without specifying its full path.

## Usage

```
disk-mark-me -t /path/to/target_directory [OPTIONS]
# or if not in PATH:
# ./disk-mark-me -t /path/to/target_directory [OPTIONS]
```

**Required Argument:**

*   `-t, --target-dir DIR`: Specifies the directory on the storage device to test. A temporary test file will be created here.

**Options:**

*   `-s, --filesize SIZE`: Test file size. Suffix 'm' for MiB (e.g., 128m, 512m) or 'g' for GiB (e.g., 1g, 2g). `fio` interprets these as IEC units (powers of 1024).
    (Default: `1g`)
*   `-r, --rounds NUM`: Number of times to run each test configuration. Results (MB/s and IOPS) will be averaged.
    (Default: `5`)
*   `-b, --benchmark TYPE`: Type of benchmark to run: 'read', 'write', or 'both'.
    (Default: `both`)
*   `-v, --verbose`: Enable verbose output, showing per-round details and more informational messages.
*   `-h, --help`: Show the help message and exit.

**Examples:**

*   Run a default benchmark (5 rounds, 1GiB file, read & write tests) on an SD card mounted at `/mnt/sdcard`:
    ```bash
    disk-mark-me -t /mnt/sdcard
    ```
*   Run only read tests, 3 rounds, using a 512MiB test file, with verbose output:
    ```bash
    disk-mark-me -t /media/my_usb -s 512m -r 3 -b read -v
    ```

## Important Notes

*   **Cross-OS Comparability (Linux vs. macOS vs. Windows):**
    *   Benchmark results obtained with `disk-mark-me` (or any tool) on one operating system (e.g., Linux on JELOS) should **not be directly compared** to results from another OS (e.g., macOS, or CrystalDiskMark on Windows), even when testing the exact same storage device.
    *   **Reasons for differences include:**
        *   **Operating System Storage Stack:** Each OS (Linux, macOS, Windows) has a unique I/O stack, drivers, caching mechanisms, and schedulers.
        *   **Hardware Interface:** The way storage is connected (e.g., direct SoC MMC controller vs. USB card reader vs. native NVMe PCIe) significantly impacts performance.
        *   **`fio` I/O Engines & OS Primitives:** `fio` uses different underlying I/O engines (`libaio` on Linux, `posixaio` on macOS) and OS-level calls for operations like direct I/O or cache flushing (`drop_caches` vs. `purge`).
        *   **Filesystem Implementation:** Even the same filesystem type (e.g., exFAT) can have different driver implementations and performance characteristics on different OSes.
    *   Use `disk-mark-me` to compare performance *within the same OS environment* or to understand the performance of a device *on that specific OS*.
*   **macOS Support (Beta):** While the script now runs on macOS, consider this support as beta. Differences in `fio`'s behavior or OS interactions compared to Linux might exist. Ensure GNU versions of `coreutils` (for `numfmt`) and `grep` (if `-P` support is needed beyond system default) are correctly installed and in your `PATH` via Homebrew.
*   **Test Duration:** Benchmarks can take a significant amount of time, especially with larger file sizes, multiple rounds, or on slower storage. Defaulting to 5 rounds will increase test time compared to a single round.
    *   **SD Card Random Write Performance:** SD cards, due to their internal flash memory architecture (erase blocks, page writes, read-modify-write cycles), can be exceptionally slow at random write tests (especially 4KiB with high queue depth like Q32), even if they have good sequential speed ratings (e.g., U3, A1/A2). This is normal. If random write tests are taking an excessively long time, consider reducing the test file size (e.g., `-s 128m` or `-s 256m`) or the number of rounds (`-r 1`) for these specific tests to get a quicker indication of performance.
*   **SD Card Wear:** Running intensive write benchmarks frequently can contribute to the wear of SD cards. Use judiciously.
*   **System Load:** For best results, ensure the system is relatively idle during the benchmark. Other I/O-intensive processes can skew results.
*   **Tool Versions:** The script is designed to work with common versions of GNU utilities. BusyBox versions (common on embedded systems) can sometimes have slightly different option support (e.g., `df -B` vs `df -k`). The script attempts to use compatible options.

## Contributing

Feel free to open an issue or submit a pull request for improvements or bug fixes.

## License

This script is released under the [MIT License](LICENSE.txt) (or choose another appropriate open-source license).
