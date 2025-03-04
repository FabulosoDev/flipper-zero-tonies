#!/usr/bin/env bash

echo "Building known tonies for each folder"

while read -r LANG_DIR; do
    NFC_FILES=()
    while IFS= read -r -d '' NFC_FILE; do
        NFC_FILES+=("${NFC_FILE}")
    done < <(find "${LANG_DIR}" -type f -name "*.nfc" -print0 | sort -z)

    FOLDER=$(basename "${LANG_DIR}")
    NFC_FILES_COUNT=${#NFC_FILES[@]}

    echo "${FOLDER} has ${NFC_FILES_COUNT}"
    {
      echo "# ${NFC_FILES_COUNT} ${FOLDER} NFC Files"
      echo ""
      echo "automatically generated, do not edit"
      echo ""
      echo "| Folder | Filename |"
      echo "|--------|----------|"
    } > "${LANG_DIR}/README.md"

    for FILE_PATH_ABS in "${NFC_FILES[@]}"; do
      FILE_NAME=$(basename "$FILE_PATH_ABS")
      FILE_PATH_REL=${FILE_PATH_ABS#"${LANG_DIR}/"}
      FILE_PATH_REL_ENC=$(echo "$FILE_PATH_REL" | awk '{gsub(/ /, "%20"); print}')
      FOLDER_NAME_REL=$(dirname "${FILE_PATH_REL}")
      printf "| %s | [%s](%s) |\n" "${FOLDER_NAME_REL}" "${FILE_NAME}" "${FILE_PATH_REL_ENC}" >> "${LANG_DIR}/README.md"
    done

done < <(find "." -maxdepth 1 -type d ! -name ".*")
