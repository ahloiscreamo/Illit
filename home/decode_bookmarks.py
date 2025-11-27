#!/usr/bin/env python3
import urllib.parse
import sys

def decode_html_content(file_path):
    """
    Reads an HTML file and decodes all percent-encoded strings 
    (like those found in URLs) back into readable characters.
    """
    try:
        # Read the file content, assuming it is UTF-8 (as specified in your HTML file)
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Perform the decoding on the entire content. 
        # This will decode the HREFs and any URL-encoded text.
        decoded_content = urllib.parse.unquote(content)

        # Print the decoded content to stdout
        print(decoded_content)

    except FileNotFoundError:
        print(f"Error: File not found at {file_path}", file=sys.stderr)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        # Pass the filename from the command line argument
        decode_html_content(sys.argv[1])
    else:
        print("Usage: python3 decode_bookmarks.py <path_to_bookmarks.html>", file=sys.stderr)
