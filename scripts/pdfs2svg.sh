#!/bin/bash

# Loop through all PDF files in the current directory
for pdf_file in *.pdf; do
	# Get the base name of the PDF file (without the .pdf extension)
	base_name="${pdf_file%.pdf}"

	# Convert the PDF to SVG
	if [[ "${pdf_file}" == "main.pdf" ]]; then
		continue
	fi
	if [[ -f "${base_name}.svg" ]]; then
		echo trash "$pdf_file"
		trash "$pdf_file"
		continue
	fi
	echo pdf2svg "$pdf_file" "${base_name}.svg"
	pdf2svg "$pdf_file" "${base_name}.svg"
	echo trash "$pdf_file"
	trash "$pdf_file"

	# Optional: print a message indicating successful conversion
	echo "Converted $pdf_file to ${base_name}.svg"
done
