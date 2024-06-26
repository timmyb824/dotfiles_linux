if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

[[ -e "/home/tbryant/oracle-cli/lib/python3.10/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/home/tbryant/oracle-cl
i/lib/python3.10/site-packages/oci_cli/bin/oci_autocomplete.sh"
