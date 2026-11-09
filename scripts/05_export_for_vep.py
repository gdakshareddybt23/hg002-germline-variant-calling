#!/usr/bin/env python3
"""Export slice-local normalized calls to true GRCh38 chr20 coordinates for VEP.

Only valid for the pinned GRCh38 chr20:10,000,000–10,500,000 (inclusive)
fixture. This does NOT lift over between genome assemblies. Do not transform
local BAM files with this script or use transformed VCF against slice reference.
"""
import gzip
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
in_vcf = root / 'results/vcf/HG002.gatk.norm.vcf.gz'
out_vcf = root / 'results/vcf/HG002.gatk.GRCh38_for_VEP.vcf'
old_chrom = 'chr20_10.0-10.5Mb'
shift = 9_999_999
if not in_vcf.exists():
    raise SystemExit(f'Missing {in_vcf}; run the previous steps.')

count = 0
with gzip.open(in_vcf, 'rt') as inp, out_vcf.open('w', encoding='utf-8') as out:
    for line in inp:
        if line.startswith('##contig=<ID=' + old_chrom):
            continue
        if line.startswith('##reference='):
            continue
        if line.startswith('#CHROM'):
            out.write('##reference=GRCh38\n')
            out.write('##contig=<ID=chr20>\n')
            out.write('##coordinate_transform=slice_pos_plus_9999999;HG002_chr20_fixture_v2026.9.39\n')
            out.write(line)
            continue
        if line.startswith('#'):
            out.write(line)
            continue
        v = line.rstrip('\n').split('\t')
        if len(v) < 8 or v[0] != old_chrom:
            raise SystemExit(f'Unexpected reference contig in input: {v[0]}')
        orig = int(v[1])
        if not 1 <= orig <= 500_001:
            raise SystemExit(f'Slice-local position outside expected range: {orig}')
        v[0] = 'chr20'
        v[1] = str(orig + shift)
        info = v[7].split(';')
        v[7] = ';'.join(('END=' + str(int(t[4:]) + shift)) if t.startswith('END=') else t for t in info)
        out.write('\t'.join(v) + '\n')
        count += 1
print(f'Converted {count} records for VEP: {out_vcf}')
print('Use Human GRCh38 in Ensembl VEP; validate allele/reference consistency before interpretation.')
