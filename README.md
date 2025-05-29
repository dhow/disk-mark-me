# disk-mark-me - Fio-based Disk Benchmark Tool

`disk-mark-me` is a shell script that uses `fio` (Flexible I/O Tester) to perform disk performance benchmarks, presenting results in a format similar to CrystalDiskMark's default profile. It is designed for Linux-based systems, particularly useful for embedded devices like handheld gaming consoles running JELOS or ROCKNIX.

## Features

*   Tests sequential and random read/write performance.
*   Mimics CrystalDiskMark's default test configurations (Block Size, Queue Depth, Threads).
*   Calculates and displays results in MB/s and IOPS.
*   Allows customization of:
    *   Target directory for the benchmark.
    *   Test file size.
    *   Number of rounds per test configuration (results are averaged).
*   Verbose mode for detailed per-round output.
*   Pre-run checks for required tools and sufficient disk space.
*   Clears disk caches before read tests for more accurate results (if permissions allow).

## Benchmark Profile

The script runs the following test configurations, mirroring CrystalDiskMark's default:

| Type | Block Size | Queues | Threads |
| :--- | :--------- | :----- | :------ |
| SEQ  | 1MiB       | 8      | 1       |
| SEQ  | 1MiB       | 1      | 1       |
| RND  | 4KiB       | 32     | 1       |
| RND  | 4KiB       | 1      | 1       |

Both Read and Write operations are tested for each configuration.

## Prerequisites

The script requires the following command-line tools to be installed and accessible in your system's `PATH`:

*   `fio`: The core I/O benchmarking engine.
*   `numfmt`: For number formatting (part of GNU Coreutils).
*   `grep`: For text searching (requires PCRE `-P` support, usually GNU grep).
*   `awk`: For text processing.
*   `bc`: For basic arithmetic calculations.
*   `df`: For checking disk free space.
*   `stat`: For checking file status (e.g., size).
*   `id`, `touch`, `rm`: Standard utilities.

`sudo` is optional but recommended if you want the script to attempt clearing disk caches before read tests (requires appropriate sudo permissions without a password prompt for the cache-clearing commands, or running the script as root).

### Prerequisites for JELOS / ROCKNIX

On JELOS/ROCKNIX, these tools can be installed via Entware.

**1. Install Entware (if not already installed):**
   Log in to your device via SSH and run the official Entware installer:
   ```bash
   /usr/sbin/installentware
   ```
   Follow the on-screen prompts. It may ask to reboot to complete the installation.

**2. Configure PATH Environment Variable:**
   After Entware is installed, you need to add its binary directories to your system's `PATH`. The Entware installer will remind you of this.
   To do this for your current session:
   ```bash
   export PATH=/opt/bin:/opt/sbin:$PATH
   ```
   To make this change permanent, add the line above to your shell's profile file. For the `root` user (common on these devices):
   ```bash
   echo 'export PATH=/opt/bin:/opt/sbin:$PATH' >> /root/.profile
   source /root/.profile # Apply for current session
   ```
   *Note: After modifying profile files, you typically need to log out and log back in, or `source` the file for the changes to take effect in your current session.*

**3. Install Required Packages via opkg:**
   Once Entware is installed and your `PATH` is configured, use `opkg` (Entware's package manager) to install the necessary tools:
   ```bash
   opkg update
   opkg install fio coreutils-numfmt coreutils
   ```
   *   `fio`: The core benchmarking tool.
   *   `coreutils-numfmt`: For the `numfmt` utility.
   *   `coreutils`: Provides Entware's versions of `df`, `stat`, `id`, `touch`, `rm`.
   *   `bc` (basic calculator), `grep`, and `awk` are usually available by default or included with Entware's base. The `disk-mark-me` script will check for their presence during startup. If `bc` (or another normally present tool) is reported as missing by the script, you can try installing it via `opkg install bc`.

**4. Verify Tools:**
   After installation, you can verify the tools are found:
   ```bash
   which fio numfmt df bc
   ```
   They should typically point to paths within `/opt/bin/`.

## Installation

1.  Download the `disk-mark-me` script to your device.
    ```bash
    # Example using curl:
    # curl -LO https://raw.githubusercontent.com/yourusername/yourrepository/main/disk-mark-me
    # Or copy it manually.
    ```
2.  Make it executable:
    ```bash
    chmod +x disk-mark-me
    ```
3.  (Optional) Move it to a directory in your `PATH` for easier access, e.g.:
    ```bash
    # mv disk-mark-me /usr/local/bin/
    # Or if using Entware's path:
    # mv disk-mark-me /opt/bin/
    ```

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

## Example Output (Non-Verbose)

```
------------------------------------------------------------------------------
disk-mark-me v1.1.3 - fio v3.37
------------------------------------------------------------------------------
* MB/s = 1,000,000 bytes/s
* Target: /storage/games-external | Test File Size: 128m (IEC) | Rounds: 5

[Read]
Running SEQ   1MiB (Q= 8, T=1)... Done.
  SEQ   1MiB (Q= 8, T=1) :    69.540 MB/s [     66.0 IOPS]
Running SEQ   1MiB (Q= 1, T=1)... Done.
  SEQ   1MiB (Q= 1, T=1) :    66.780 MB/s [     63.0 IOPS]
Running RND   4KiB (Q=32, T=1)... Done.
  RND   4KiB (Q=32, T=1) :     8.807 MB/s [   2150.4 IOPS]
Running RND   4KiB (Q= 1, T=1)... Done.
  RND   4KiB (Q= 1, T=1) :     6.570 MB/s [   1604.2 IOPS]

[Write]
Running SEQ   1MiB (Q= 8, T=1)... Done.
  SEQ   1MiB (Q= 8, T=1) :    32.020 MB/s [     30.0 IOPS]
Running SEQ   1MiB (Q= 1, T=1)... Done.
  SEQ   1MiB (Q= 1, T=1) :    45.120 MB/s [     42.6 IOPS]
Running RND   4KiB (Q=32, T=1)... Done.
  RND   4KiB (Q=32, T=1) :     3.137 MB/s [    766.0 IOPS]
Running RND   4KiB (Q= 1, T=1)... Done.
  RND   4KiB (Q= 1, T=1) :     2.807 MB/s [    685.6 IOPS]

Benchmark complete.
```

## How it Works

1.  **Setup:**
    *   Parses command-line arguments.
    *   Checks for required tools.
    *   Verifies the target directory exists and is writable.
    *   Checks for sufficient disk space (at least 2x the test file size).
2.  **Benchmarking:**
    *   For each test configuration ([Read] then [Write]):
        *   Iterates for the specified number of rounds.
        *   **Read Tests:**
            *   If it's the first read operation, a test file of `filesize` is created in the `target-dir`.
            *   Attempts to clear system disk caches (if `sudo` access allows or running as root).
            *   Runs `fio` with the specified parameters (`rw=read` or `rw=randread`, block size, iodepth, numjobs, etc.), using direct I/O to bypass OS caching.
        *   **Write Tests:**
            *   The existing test file is removed once before the entire [Write] section.
            *   Runs `fio` (`rw=write` or `rw=randwrite`). `fio` creates/overwrites the test file.
        *   Parses `fio` output for MB/s and IOPS.
        *   For 4KiB random tests, if `fio` reports 0.000 MB/s but non-zero IOPS, MB/s is calculated from IOPS.
    *   Averages the MB/s and IOPS results across all successful rounds for that configuration.
    *   Prints the final averaged result.
3.  **Cleanup:**
    *   Deletes the temporary test file from the target directory.

## Important Notes

*   **Test Duration:** Benchmarks can take a significant amount of time, especially with larger file sizes, multiple rounds, or on slower storage.
*   **SD Card Wear:** Running intensive write benchmarks frequently can contribute to the wear of SD cards. Use judiciously.
*   **System Load:** For best results, ensure the system is relatively idle during the benchmark. Other I/O-intensive processes can skew results.
*   **`numfmt` and `df` behavior:** The script is designed to work with GNU `numfmt` and POSIX-compliant `df`. BusyBox versions (common on embedded systems) can sometimes have slightly different option support. The script attempts to use common options (`df -P -k`).

## Contributing

Feel free to open an issue or submit a pull request for improvements or bug fixes.

## License

This script is released under the [MIT License](LICENSE.txt) (or choose another appropriate open-source license).
