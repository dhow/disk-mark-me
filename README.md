# disk-mark-me - CrystalDiskMark-alike disk benchmark on Linux

`disk-mark-me` is a shell script that presents disk benchmark results in a format similar to CrystalDiskMark's default profile, by leveraging `fio` (Flexible I/O Tester). It is designed for Linux-based systems, including embedded devices like handheld gaming consoles running JELOS or ROCKNIX.

## Features

*   Tests sequential and random read/write performance.
*   Mimics CrystalDiskMark's default test configurations (Block Size, Queue Depth, Threads).
*   Calculates and displays results in MB/s and IOPS.
*   Allows customization of:
    *   Target directory for the benchmark.
    *   Test file size.
    *   Number of rounds per test configuration (results are averaged).
*   Verbose mode for detailed per-round output and informational messages.
*   Pre-run checks for required tools and sufficient disk space.
*   Clears disk caches before read tests for more accurate results (if permissions allow).

## Benchmark Profile

The script runs the following test configurations, mirroring CrystalDiskMark's default:

| Type | Block Size | Queues | Threads |
| :--- | :--------- | :----- | :------ |
| SEQ  | 1 MiB      | 8      | 1       |
| SEQ  | 1 MiB      | 1      | 1       |
| RND  | 4 KiB      | 32     | 1       |
| RND  | 4 KiB      | 1      | 1       |

Both Read and Write operations are tested for each configuration.

## Prerequisites

The script requires the following command-line tools to be installed and accessible in your system's `PATH`:

*   `fio`: The core I/O benchmarking engine.
*   `numfmt`: For number formatting (part of GNU Coreutils).
*   Standard utilities: `grep` (with PCRE/-P support), `awk` (GNU awk `gawk` recommended if available), `bc`, `df`, `stat`, `id`, `touch`, and `rm`. These are usually present on most Linux systems, but the script will check for them.

`sudo` is optional but recommended if you want the script to attempt clearing disk caches before read tests (requires appropriate sudo permissions without a password prompt for the cache-clearing commands, or running the script as root).

### Prerequisites for JELOS / ROCKNIX

On JELOS/ROCKNIX, these tools can be installed via Entware.

**1. Install Entware (if not already installed):**
   Log in to your device via SSH and run the official Entware installer:
   ```bash
   /usr/sbin/installentware
   ```
   Follow the on-screen prompts. It may ask to reboot to complete the installation.

**2. Configure PATH Environment Variable (if needed):**
   After Entware is installed (and after a reboot if prompted), ensure `/opt/bin` and `/opt/sbin` are in your system's `PATH`. The Entware installer typically reminds you or sets this up.
   To check your current PATH: `echo $PATH`
   If `/opt/bin` is missing, for your current session:
   ```bash
   export PATH=/opt/bin:/opt/sbin:$PATH
   ```
   To make this change permanent (example for the `root` user):
   ```bash
   echo 'export PATH=/opt/bin:/opt/sbin:$PATH' >> /root/.profile
   # Then log out and log back in, or run: source /root/.profile
   ```

**3. Install Required Packages via opkg:**
   Use `opkg` (Entware's package manager) to install the necessary tools:
   ```bash
   opkg update
   opkg install fio coreutils coreutils-numfmt
   ```
   *   `fio`: The core benchmarking tool.
   *   `coreutils`: Provides Entware's versions of `df`, `stat`, `id`, `touch`, `rm`.
   *   `coreutils-numfmt`: For the `numfmt` utility.

**4. Verify Tools:**
   After installation, you can verify the tools are found:

   ```bash
   which fio numfmt
   ```
   They should typically point to paths within `/opt/bin/`.

## Installation

There are two main ways to install `disk-mark-me`:

**Method 1: Manual Installation**

1.  Download the `disk-mark-me` script to your device.
    ```bash
    # Example using curl (ensure the URL points to the raw script file):
    curl -LO https://raw.githubusercontent.com/dhow/disk-mark-me/refs/heads/main/disk-mark-me
    # Or copy it manually.
    ```
2.  Make it executable:
    ```bash
    chmod +x disk-mark-me
    ```
3.  You can now run it directly from its current location (e.g., `./disk-mark-me ...`).

**Method 2: Using the Makefile (Recommended for easy updates/uninstalls)**

If you have `make` installed on your system and have downloaded both `disk-mark-me` and its `Makefile` into the same directory:

1.  **Download Script and Makefile:**
    Ensure both `disk-mark-me` and `Makefile` are in your current directory.
    
    ```bash
    # Example using curl for both:
    curl -LO https://raw.githubusercontent.com/dhow/disk-mark-me/refs/heads/main/disk-mark-me
    curl -LO https://raw.githubusercontent.com/dhow/disk-mark-me/refs/heads/main/Makefile
    chmod +x disk-mark-me # Make the script executable
    ```
    
2.  **Install:**
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
    If you've downloaded a new version of `disk-mark-me` (and potentially `Makefile`) into the same directory where you previously ran `make install`:
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

**After Installation (Both Methods):**

*   Ensure the installation directory (e.g., `~/.local/bin` or `/usr/local/bin`) is included in your system's `PATH` environment variable.
*   You may need to start a new shell session or `source` your shell's profile file (e.g., `~/.bashrc`, `~/.zshrc`, `~/.profile`) for the command to be recognized without specifying its full path.

## Usage

```
./disk-mark-me -t /path/to/target_directory [OPTIONS]
```

**Required Argument:**

*   `-t, --target-dir DIR`: Specifies the directory on the storage device to test. A temporary test file will be created here.

**Options:**

*   `-s, --filesize SIZE`: Test file size. Suffix 'm' for MiB (e.g., 128m, 512m) or 'g' for GiB (e.g., 1g, 2g). `fio` interprets these as IEC units (powers of 1024).
    (Default: `1g`)
*   `-r, --rounds NUM`: Number of times to run each test configuration. Results (MB/s and IOPS) will be averaged.
    (Default: `1`)
*   `-v, --verbose`: Enable verbose output, showing per-round details and more informational messages.
*   `-h, --help`: Show the help message and exit.

**Examples:**

*   Run a default benchmark on an SD card mounted at `/mnt/sdcard`:
    ```bash
    ./disk-mark-me -t /mnt/sdcard
    ```
*   Run 3 rounds using a 512MiB test file, with verbose output:
    ```bash
    ./disk-mark-me -t /media/my_usb -s 512m -r 3 -v
    ```

## Example Output (Non-Verbose, v1.1.5)

```
------------------------------------------------------------------------------
disk-mark-me v1.1.5 - fio v3.37 
------------------------------------------------------------------------------
* MB/s = 1,000,000 bytes/s
* Target: . | Test File Size: 1g (IEC) | Rounds: 1

[Read]
  SEQ   1MiB (Q= 8, T=1) : 19503.513 MB/s [  18600.0 IOPS]
  SEQ   1MiB (Q= 1, T=1) :  5681.000 MB/s [   5417.0 IOPS]
  RND   4KiB (Q=32, T=1) :   963.000 MB/s [ 235000.0 IOPS]
  RND   4KiB (Q= 1, T=1) :    89.600 MB/s [  21900.0 IOPS]

[Write]
  SEQ   1MiB (Q= 8, T=1) :  3016.000 MB/s [   2876.0 IOPS]
  SEQ   1MiB (Q= 1, T=1) :  2926.000 MB/s [   2790.0 IOPS]
  RND   4KiB (Q=32, T=1) :   987.000 MB/s [ 241000.0 IOPS]
  RND   4KiB (Q= 1, T=1) :    81.200 MB/s [  19800.0 IOPS]

Benchmark complete.
```

## Important Notes

*   **Test Duration:** Benchmarks can take a significant amount of time, especially with larger file sizes, multiple rounds, or on slower storage.
*   **SD Card Wear:** Running intensive write benchmarks frequently can contribute to the wear of SD cards. Use judiciously.
*   **System Load:** For best results, ensure the system is relatively idle during the benchmark. Other I/O-intensive processes can skew results.
*   **Tool Versions:** The script is designed to work with common versions of GNU utilities. BusyBox versions (common on embedded systems) can sometimes have slightly different option support (e.g., `df -B` vs `df -k`). The script attempts to use compatible options.

## Contributing

Feel free to open an issue or submit a pull request for improvements or bug fixes.

## License

This script is released under the [MIT License](LICENSE.txt) (or choose another appropriate open-source license).

