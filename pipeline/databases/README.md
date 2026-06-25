Demo Kraken2 database: demo_crypto_giardia
==========================================

This directory contains a minimal Kraken2 database built from a small set of
Cryptosporidium and Giardia reference sequences. It is intended only for
demonstrating the ODIN taxprofiler workflow — not for real diagnostic use.

The database is tracked with Git LFS. If the .k2d files look like plain-text
pointer files (~130 bytes), run:

    git lfs install
    git lfs pull

Contents of demo_crypto_giardia/:
  hash.k2d                     Kraken2 hash table
  opts.k2d                     Kraken2 database options
  taxo.k2d                     Kraken2 taxonomy
  seqid2taxid.map              Sequence-to-taxon mapping
  database150mers.kmer_distrib Bracken k-mer distribution (150 bp read length)
