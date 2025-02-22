#!/usr/bin/env bash

ERROR_FOUND=0

REQUIRED_PATTERNS=(
  "^Filetype: Flipper NFC device$"
  "^Version: 4$"
  "^Device type: SLIX$"
  "^UID:( [A-F0-9]{2}){8}$"
  "^DSFID: 00$"
  "^AFI: 00$"
  "^IC Reference: 03$"
  "^Lock DSFID: false$"
  "^Lock AFI: false$"
  "^Block Count: 8$"
  "^Block Size: 04$"
  "^Data Content:( [A-F0-9]{2}){32}$"
  "^Security Status: 00 00 00 00 00 00 00 00$"
  "^Capabilities: Default$"
  "^Password Privacy: 7F FD 6E 5B$"
  "^Password Destroy: 0F 0F 0F 0F$"
  "^Password EAS: 00 00 00 00$"
  "^Privacy Mode: false$"
  "^Lock EAS: false$"
)

FORBIDDEN_PATTERNS=(
  # This showed up in Unleashed firmware, see https://github.com/nortakales/flipper-zero-tonies/pull/82
  "Subtype: ([0-9]){2}"
)

# Use process substitution so that ERROR_FOUND is updated in the main shell.
while read -r filename; do
  content=$(cat "$filename")

  for pattern in "${REQUIRED_PATTERNS[@]}"; do
    if ! echo "$content" | awk "/$pattern/ { found=1 } END { exit !found }"; then
      echo "$filename"
      echo "    Missing pattern: $pattern"
      ERROR_FOUND=1
    fi
  done

  for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if echo "$content" | awk "/$pattern/ { found=1 } END { exit !found }"; then
      echo "$filename"
      echo "    Forbidden pattern found: $pattern"
      ERROR_FOUND=1
    fi
  done

  # The likelihood of two blocks of 00 in data content is almost impossible,
  # so use that as a check for when the full data is not read
  if echo "$content" | awk '/Data Content:( [A-F0-9]{2})* 00 00( [A-F0-9]{2})*/ { found=1 } END { exit !found }'; then
    echo "$filename"
    echo "    Full data not read"
    ERROR_FOUND=1
  fi

  # Not necessarily going to cause issues, but keep line endings the same for consistency
  if echo "$content" | awk '/\r/ { found=1 } END { exit !found }'; then
    echo "$filename"
    echo "    Has carriage return characters"
    ERROR_FOUND=1
  fi


done < <(find . -type f -name "*.nfc")

exit $ERROR_FOUND
