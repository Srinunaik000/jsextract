# JS Recon Tool

A Bash-based automation tool for JavaScript file reconnaissance. It helps you find JavaScript files, extract potential secrets and endpoints, and run static analysis tools like LinkFinder and SecretFinder.

## 🛠 Features

- ✅ Extract JS endpoints manually (regex-based)
- 🔐 Extract potential secrets (tokens, API keys, etc.)
- 🔗 Run [LinkFinder](https://github.com/GerbenJavado/LinkFinder)
- 🕵️ Run [SecretFinder](https://github.com/m4ll0k/SecretFinder)
- 🔄 Collect JS files from:
  - `subjs`
  - `gau`
  - `waybackurls`
- 📂 Organizes output into subfolders

## 📦 Output Structure

js_recon/
- ├── output/ # Collected JS URLs (subjs, gau, wayback)
- ├── extracted_endpoints/ # Manual regex-based endpoint extraction
- ├── extracted_secrets/ # Manual regex-based secret extraction
- ├── linkfinder/ # Output from LinkFinder
- ├── secretfinder/ # Output from SecretFinder


## Usage

```bash
chmod +x jsrecon.sh
./jsrecon.sh [OPTIONS]

Options:
Flag	Description
-u <js_url>	Extract from a single JavaScript file URL
-f <file>	Extract from a list of JavaScript URLs (one per line)
-d <domain.com>	Full recon: subjs + gau + waybackurls + extraction
-h	Show help message


## Example Usage

- Extract from one JS file:
./jsrecon.sh -u https://example.com/app.js

- Extract from a list:
./jsrecon.sh -f jslist.txt

-Run full recon on a domain:
./jsrecon.sh -d target.com

## Requirements
- Make sure the following tools are installed and available in $PATH:
curl
md5sum
subfinder
subjs
gau
waybackurls
linkfinder
secretfinder

## License
MIT

## Credits
LinkFinder
SecretFinder

- Let me know if you want a version with installation instructions for dependencies or a sample output file!
