#!/bin/bash

wget -O Sandbox.csv 'https://drive.google.com/uc?export=download&id=1cC6MYBI3wRwDgqlFQE1OQUN83JAreId0'

echo "Pelanggan dengan sales tertinggi: "
echo "$(cat Sandbox.csv)" | awk -F ',' '{print $6",",$17}' | sort -t ',' -k2,2nr | head -n 1
echo ""

echo "Segment pelanggan dengan profit paling kecil: "
echo "$(cat Sandbox.csv)" | awk -F ',' '{print $7",",$20}' | sort -t ',' -k2,2n | head -n 2 | tail -n 1
echo ""

echo "3 kategori dengan total profit tertinggi: "
echo "$(cat Sandbox.csv)" | awk -F ',' '{ categories[$14] += $20 } END { for (cat in categories) print cat",", categories[cat] }' | sort -t ',' -k2,2nr | head -n 3
echo ""

echo "Tanggal pembelian dan jumlah/kuantitas dari pelanggan Adriaens: "
echo "$(cat Sandbox.csv)" | awk -F ',' '/Adriaens/ {print "Nama Pelanggan: "$6,"\nTanggal Pembelian: "$2,"\nJumlah Pesanan: "$18}'
