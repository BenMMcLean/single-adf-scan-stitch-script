#!/bin/bash

front_pdf="$1"
back_pdf="$2"
output_pdf="$3"

# Number of pages in the document
total_pages=$(pdfinfo "$front_pdf" | grep Pages | awk '{print $2}')

# Split the front and back PDFs into individual pages
mkdir front_pages back_pages
pdfseparate "$front_pdf" front_pages/page_%d.pdf
pdfseparate "$back_pdf" back_pages/page_%d.pdf

# Interleave the pages: front, back in reverse order
for ((i=1; i<=$total_pages; i++)); do
  pdfunite "front_pages/page_$i.pdf" "back_pages/page_$((total_pages - i + 1)).pdf" "temp_$i.pdf"
done

# Combine all temp files into the final stitched PDF
pdfunite temp_*.pdf "$output_pdf"

# Clean up
rm -rf front_pages back_pages temp_*.pdf

echo "Finished stitching. Output saved to $output_pdf"