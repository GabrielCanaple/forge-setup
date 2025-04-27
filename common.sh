color_for_level() {
    case "$1" in
        "INFO") echo -e "\e[32m" ;;
        "WARNING") echo -e "\e[33m" ;;
        "ERROR") echo -e "\e[31m" ;;
        *) echo -e "\e[0m" ;;
    esac
}

log_message() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +"%H:%M:%S")

    local color=$(color_for_level "$level")
    echo -e  "${color}[$timestamp] [$level]\033[0m $message"
}

info() {
    log_message "INFO" "$@"
}

warning() {
    log_message "WARNING" "$@"
}

error() {
    log_message "ERROR" "$@"
}

execute_scripts_in_folder() {
    folder=$1
    for script in "$folder"/*.sh; do
    if [[ -f "$script" ]]; then
        if [[ -x "$script" ]]; then
            echo "Skipping $script: not executable."
            continue
        fi

        info "Executing script $script"


        bash -e "$script" || {
            error "Error executing $script, exiting..."
            return 1
        }
else
    info "Skipping $script: not a file."
fi
done
}

prompt_yes_no(){
while true; do
    read response
    case $response in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "(y/n): "
    esac
done
}

add_line_to_file_if_not_exists_root(){
    if ! grep -qE "^\s*${2}\b" "${1}"; then
        echo ${2} | sudo tee -a ${1} > /dev/null
    else
        info "Skipping setting up ${2} in ${1}: already present."
    fi
}
