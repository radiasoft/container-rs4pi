#!/bin/bash

build_vars() {
    export sirepo_db_dir=/sirepo
    export sirepo_port=8000
    build_image_base=radiasoft/beamsim
    local boot_dir=$build_run_user_home/.radia-run
    sirepo_tini_file=$boot_dir/tini
    sirepo_boot=$boot_dir/start
    build_docker_cmd='["'"$sirepo_tini_file"'", "--", "'"$sirepo_boot"'"]'
}

build_as_root() {
    build_yum install postgresql-devel
}

build_as_run_user() {
    cd "$build_guest_conf"
    sirepo_boot_init
    # reinstall pykern always
    build_curl radia.run | bash -s code pykern
    git clone -q --depth=50 "--branch=rs4pi" \
        https://github.com/radiasoft/sirepo
    cd sirepo
    pip install -r requirements.txt
    python setup.py install
    cd ..

}

sirepo_boot_init() {
    mkdir -p "$(dirname "$sirepo_boot")"
    build_replace_vars radia-run.sh "$sirepo_boot"
    chmod +x "$sirepo_boot"
    build_curl https://github.com/krallin/tini/releases/download/v0.9.0/tini > "$sirepo_tini_file"
    chmod +x "$sirepo_tini_file"

}

build_vars
