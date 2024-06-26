if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

[[ -e "/home/tbryant/oracle-cli/lib/python3.11/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/home/tbryant/oracle-cli/lib/python3.11/site-packages/oci_cli/bin/oci_autocomplete.sh"
