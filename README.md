# ODIN Demo Data

Self-contained demo data for running the ODIN application with both Nanopore and Biomeme examples.

## About ODIN

ODIN is a browser-based application for registering, launching, and tracking sequencing and qPCR workflows.

- Dashboard discovery and registration for MinKNOW and Biomeme inputs
- Pipeline launch and monitoring
- Settings-driven path configuration
- Integration hooks for Enlighten

This repository is the **demo companion** to the ODIN pipeline web application.
It provides pre-populated sample data, seed files, and a ready-to-run Docker Compose stack so you can explore ODIN without setting up real sequencing data.

The application runs as two Docker containers pulled automatically from Docker Hub:
- [`norceresearch1/odin-mobilelab-api`](https://hub.docker.com/r/norceresearch1/odin-mobilelab-api) — FastAPI backend + Nextflow
- [`norceresearch1/odin-mobilelab-ui`](https://hub.docker.com/r/norceresearch1/odin-mobilelab-ui) — nginx-served Angular frontend

Source code and full documentation are available at the [ODIN-consortium GitHub organisation](https://github.com/ODIN-consortium).

## Repository layout

The repository root holds deployment/bootstrap files. Runtime data and configuration live under `pipeline/`, which is used as `ODIN_PIPELINE_ROOT`.

```text
pipeline/
  minknow/
    DemoExperiment/
      DemoSample1/
        20260610_0800_MN37872_FAX00001_aabb1234/   ← metagenomics run 1
          fastq_pass/
            barcode01/
            barcode02/
      DemoSample2/
        20260611_0800_MN37872_FAX00002_ccdd5678/   ← metagenomics run 2
          fastq_pass/
            barcode01/
            barcode02/
      MpoxDemoRun/
        20260115_0800_MN37872_FAX00003_ee112233/   ← mpox amplicon run
          fastq_pass/
            barcode01/
  biomeme/
    biomeme_input_data/
      AA/
        20240115/
        20240116/
        20240117/
      BB/
        20240210/
        20240211/
        20240212/
    biomeme_processed/
  seed/
    /
  databases/
    demo_crypto_giardia/
      /
  config/
    /
  input_sheets/
  ca/
  nf/
    assets/
    store/
  output/
```

## Included demo data

### Nanopore demo — metagenomics (taxprofiler / wf-metagenomics)

Two MinKNOW runs intended for metagenomic classification pipelines (taxprofiler, wf-metagenomics AMR/SSU):

| Run accession | Barcodes | Experiment | Sample |
|---|---|---|---|
| `20260610_0800_MN37872_FAX00001_aabb1234` | barcode01, barcode02 | DemoExperiment | DemoSample1 |
| `20260611_0800_MN37872_FAX00002_ccdd5678` | barcode01, barcode02 | DemoExperiment | DemoSample2 |

- Kit: Rapid Barcoding Kit (RB_GEN, P2 protocol)
- Pre-registered in `seed/nanopore.csv`
- Sites/samples in `seed/sites.csv` and `seed/samples.csv` (`DEMO_*` entries)

### Nanopore demo — mpox amplicon (artic-mpxv-nf)

One MinKNOW run with anonymized mpox sequencing data for the artic-mpxv-nf amplicon pipeline:

| Run accession | Barcodes | Experiment | Sample |
|---|---|---|---|
| `20260115_0800_MN37872_FAX00003_ee112233` | barcode01 | DemoExperiment | MpoxDemoRun |

- Kit: Rapid Barcoding Kit 114-24 (SQK-RBK114-24, P5 protocol) — amplicon sequencing
- Scheme: `artic-inrb-mpox/2500/v1.0.0`
- Clade: select **Mpox Clade Ia** or **Mpox Clade Ib** when launching
- Pre-registered in `seed/nanopore.csv` (same file as the metagenomics runs)
- Uses the same `DEMO_*` sites/samples as the metagenomics runs

### Biomeme demo

- 6 anonymized Biomeme Excel files across two dummy countries (`AA`, `BB`)
- Seed mapping is in `seed/biomeme.csv`
- Supporting dummy sites/samples are included in `seed/sites.csv` and `seed/samples.csv` (`AADS1_*`, `BBDS1_*` entries)
- Files are intentionally minimized to the rows ODIN uses for parsing, so behavior matches real ingestion while removing unused metadata

## Quick start

### 1. Prerequisites

#### Git LFS

Large binary files (FASTQ, Kraken2 databases) are stored with [Git Large File Storage](https://git-lfs.com/).
Installing Git LFS requires two steps — first install the package, then activate it in git:

**Linux / WSL2 (Debian/Ubuntu):**
```bash
sudo apt-get install git-lfs
git lfs install        # activates LFS hooks in your global git config
```

**Linux (RPM-based — Fedora, RHEL, Rocky):**
```bash
sudo dnf install git-lfs
git lfs install
```

**macOS:**
```bash
brew install git-lfs
git lfs install
```

**Windows (native Git for Windows):**
Download and run the installer from [https://git-lfs.com/](https://git-lfs.com/), then open Git Bash and run:
```bash
git lfs install
```

> **Install Git LFS *before* cloning.** Running only `git lfs install` without first installing the package will fail silently — `git lfs` will not be recognised. If you cloned before LFS was set up, see the note in step 2.

#### Docker

A container runtime is required to run the ODIN application and its pipelines.

**Windows:** Install [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/) and enable the **WSL2 backend** during setup (Settings → Resources → WSL Integration). This is the supported configuration for running ODIN on Windows.

**Linux:** Install [Docker Engine](https://docs.docker.com/engine/install/) for your distribution, then add your user to the `docker` group:
```bash
sudo usermod -aG docker $USER   # log out and back in afterwards
```

**macOS:** Install [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/).


### 2. Clone the repository

> **This demo is designed to run under Linux or WSL2 (Windows Subsystem for Linux).**
> All commands below must be run from a Linux or WSL2 shell — not from Windows CMD or PowerShell.

**Preferred:** clone directly from within Linux/WSL2 so that all paths are native Linux paths from the start:

```bash
git clone https://github.com/ODIN-consortium/DEMO-odin-pipeline-web-application.git odin_demo
```

The trailing `odin_demo` gives the local directory a shorter name — omit it if you prefer the full repo name.

**If you cloned from Windows** (e.g. with Git for Windows or a GUI), the repo will be on your Windows filesystem. You can still use it, but you must `cd` into it from your WSL2 shell using the Linux-style mount path:

```bash
# Example — adjust the path to match where you cloned it
cd /mnt/c/Users/<your-username>/odin_demo
```

**If you cloned BEFORE installing Git LFS:**  
Your `.fastq.gz` and database files will be small "pointer" files (approx 130 bytes) and the pipeline will fail. To fix this, install Git LFS and run:
```bash
git lfs install
git lfs pull
```

### 3. Create `.env` & One-time Setup

From your **Linux or WSL2 shell**, inside the repo directory:

```bash
bash setup.sh
```

This script performs several automated tasks:
*   Generates a `.env` file with `ODIN_PIPELINE_ROOT` set correctly.
*   Checks if Git LFS is configured and pulls missing binary data.
*   Auto-detects corporate CA certificates from your environment variables.

> **Must be run from Linux/WSL2**, not from Windows CMD or PowerShell. The script sets `ODIN_PIPELINE_ROOT` to the current working directory as a Linux path — if you run it from Windows the path will be wrong and pipelines will fail to find their data.

### 4. Start the stack

```bash
docker compose up -d
```

Open UI: `http://localhost`

### 5. Explore

- Open Dashboard and scan discovery sources
- Nanopore demo runs should appear from `pipeline/minknow`
- Biomeme folders (`AA`, `BB`) should appear from `pipeline/biomeme/biomeme_input_data`
- Use Register/Launch flows from the Dashboard

## Seeds and local DB behavior

Seed files are read from `ODIN_SEED_DIR` (default: `$ODIN_PIPELINE_ROOT/seed`).

- Seeding inserts missing records
- Existing rows are not overwritten automatically
- If you change seed content and want a clean reseed, clear the relevant tables from the UI or via SQL.

## Databases and pipeline notes

- `pipeline/databases/demo_crypto_giardia/` is included as a demo Kraken2 database folder
- For `taxprofiler`, ensure your selected database is present and referenced in `pipeline/config/databases.csv`
- Additional pipelines may download/cache assets under `pipeline/nf/store`

## Corporate network (SSL inspection)

If HTTPS traffic is intercepted by a corporate CA, the `setup.sh` script will attempt to auto-detect certificates from your environment (`$CURL_CA_BUNDLE`, etc.). You can also manually place certs (`*.cer`, `*.crt`, `*.pem`) in `pipeline/ca/` and restart:

```bash
docker compose up -d
```

The ODIN backend will auto-discover and trust any certificates in that directory on startup.

## Git LFS in this repo

Large binary files are tracked with Git LFS (see `.gitattributes`):

- `*.fastq.gz`
- `*.k2d`
- `*.kmer_distrib`

If you cloned without LFS installed, your `.fastq.gz` files will look like this:
```text
version https://git-lfs.github.com/spec/v1
oid sha256:7f...
size 12345
```
Install the Git LFS package (see step 1 of Quick start for OS-specific instructions), then run:
```bash
git lfs install   # activate LFS hooks — only needed once per machine
git lfs pull      # download the actual binary files
```

## Useful cleanup

Remove generated runtime/cache/output data while keeping committed inputs:

```bash
git clean -fdx pipeline/nf/ pipeline/output/
```

### Full demo reset

To completely reset the demo to a clean state — including wiping the ODIN database so that seed data is re-imported on next startup:

```bash
docker compose down -v
docker compose up -d
```

The `-v` flag removes the named Docker volume that holds the SQLite database. On next `up`, ODIN will start fresh and re-seed sites, samples, and nanopore runs from the seed CSV files.

