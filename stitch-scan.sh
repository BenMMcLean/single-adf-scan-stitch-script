#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <front_pdf> <back_pdf> <output_pdf>"
  exit 1
fi

front_pdf="$1"
back_pdf="$2"
output_pdf="$3"

# Check if both files exist
if [ ! -f "$front_pdf" ]; then
  echo "Error: Front PDF '$front_pdf' does not exist."
  exit 1
fi

if [ ! -f "$back_pdf" ]; then
  echo "Error: Back PDF '$back_pdf' does not exist."
  exit 1
fi

# Number of pages in the document
total_pages=$(pdfinfo "$front_pdf" | grep Pages | awk '{print $2}')
back_pages=$(pdfinfo "$back_pdf" | grep Pages | awk '{print $2}')

# Check if both PDFs have the same number of pages
if [ "$total_pages" -ne "$back_pages" ]; then
  echo "Error: The front and back PDFs have a different number of pages."
  echo "Front PDF has $total_pages pages, and Back PDF has $back_pages pages."
  exit 1
fi


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