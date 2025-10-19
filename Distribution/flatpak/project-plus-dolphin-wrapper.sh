#!/bin/sh
# shellcheck shell=sh

:   "${XDG_DATA_HOME:="${HOME?}/.local/share"}" \
    "${XDG_CONFIG_HOME:="${HOME?}/.config"}" \
    "${XDG_STATE_HOME:="${HOME?}/.local/state"}" \
    "${XDG_CACHE_HOME:="${HOME?}/.local/cache"}"
export XDG_DATA_HOME XDG_CONFIG_HOME XDG_STATE_HOME XDG_CACHE_HOME

printf '%s\n' "Setting up Discord rich presence"
for discord_rpc_tmpdir in "${XDG_RUNTIME_DIR-}" "${TMPDIR-}" "${TMP-}" "${TEMP-}" '/tmp'; do
    case "${discord_rpc_tmpdir?}" in ?*)
        discord_ipc_pipe_index='0'
        while [ "${discord_ipc_pipe_index?}" -le '9' ]; do
            discord_ipc_pipe="${discord_rpc_tmpdir?}/discord-ipc-${discord_ipc_pipe_index?}"
            if ln -s -- "app/com.discordapp.Discord/discord-ipc-${discord_ipc_pipe_index?}" "${discord_ipc_pipe?}"; then
                printf '%s\n' "Set up Discord rich presence using socket ${discord_ipc_pipe?}"
                break 2
            fi
            : "$((discord_ipc_pipe_index += 1))"
        done
    esac
done

:   "${DOLPHIN_EMU_DATAPATH:="/app/share/project-plus-dolphin"}"
:   "${DOLPHIN_EMU_SYSPATH:="${DOLPHIN_EMU_DATAPATH?}/sys"}" \
    "${DOLPHIN_EMU_FACTORY_USERPATH:="${DOLPHIN_EMU_DATAPATH?}/user"}" \
    "${DOLPHIN_EMU_USERPATH:="${XDG_DATA_HOME?}/project-plus-dolphin/user"}"
export DOLPHIN_EMU_USERPATH

printf '%s\n' "Making user directory ${DOLPHIN_EMU_USERPATH?}/Wii if it doesn't exist"
mkdir -p -- "${DOLPHIN_EMU_USERPATH?}/Wii"

printf '%s\n' "Making user config directory ${XDG_CONFIG_HOME?}/project-plus-dolphin if it doesn't exist"
mkdir -p -- "${XDG_CONFIG_HOME?}/project-plus-dolphin"

# printf '%s\n' "Checking if there is a newer SD card version"
# # Create and set variables for the system and user SD card creation dates
# dolphin_emu_sys_sd_card="${DOLPHIN_EMU_SYSPATH?}/Load/WiiSD.raw" \
#     dolphin_emu_user_sd_card="${DOLPHIN_EMU_USERPATH?}/Load/WiiSD.raw"
# dolphin_emu_sys_sd_card_ctime="$(stat --format="%W" --dereference -- "${dolphin_emu_sys_sd_card?}")"
# dolphin_emu_user_sd_card_ctime="$(stat --format="%W" --dereference -- "${dolphin_emu_user_sd_card?}")"
# # Compare system and user SD cards' creation dates
# if [ "${dolphin_emu_sys_sd_card_ctime:-0}" -gt "${dolphin_emu_user_sd_card_ctime:-0}" ]; then
#     printf '%s\n' "Making user SD card parent directory ${dolphin_emu_user_sd_card%/*} if it doesn't exist"
#     mkdir -p -- "${dolphin_emu_user_sd_card%/*}"
#
#     printf '%s\n' "Copying SD card from sys directory to user directory, replacing any existing destination file with an older modification time"
#     cp --no-target-directory --update=older -- "${dolphin_emu_sys_sd_card?}" "${dolphin_emu_user_sd_card?}"
# else
#     printf '%s\n' "Not copying SD card because sys SD card${dolphin_emu_sys_sd_card_ctime:+" (created $(date -d "$dolphin_emu_sys_sd_card_ctime"))"} was not created after user SD card${dolphin_emu_user_sd_card_ctime:+" (created $(date -d "$dolphin_emu_user_sd_card_ctime"))"}"
# fi

printf '%s\n' "Copy launcher files from sys directory to user directory, replacing no existing destination files"
cp -R --no-target-directory --update=none -- "${DOLPHIN_EMU_SYSPATH}/Wii/Launcher" "${DOLPHIN_EMU_USERPATH}/Wii/Launcher"

printf '%s\n' "Copy all files from factory user directory to user directory, replacing any existing destination file with an older modification time"
cp -R --no-target-directory --update=older -- "${DOLPHIN_EMU_FACTORY_USERPATH}" "${DOLPHIN_EMU_USERPATH}"

printf '%s\n' "Checking if there are newer HD RSBE01 textures"
# Create and set variables for the system and user HD texture directories' creation dates
dolphin_emu_sys_textures_dir="${DOLPHIN_EMU_SYSPATH?}/Load/Textures/RSBE01" \
    dolphin_emu_user_textures_dir="${DOLPHIN_EMU_USERPATH?}/Load/Textures/RSBE01"
dolphin_emu_sys_textures_ctime="$(stat --format="%W" --dereference -- "${dolphin_emu_sys_textures_dir?}")"
dolphin_emu_user_textures_ctime="$(stat --format="%W" --dereference -- "${dolphin_emu_user_textures_dir?}")"
# Compare system and user HD texture directories' creation dates
if [ "${dolphin_emu_sys_textures_ctime:-0}" -gt "${dolphin_emu_user_textures_ctime:-0}" ]; then
    printf '%s\n' "Making user textures directory ${dolphin_emu_user_textures_dir%/*} if it doesn't exist"
    mkdir -p -- "${dolphin_emu_user_textures_dir%/*}"

    printf '%s\n' "Copying RSBE01 textures from sys directory to user directory, replacing any existing destination file with an older modification time"
    cp -R --no-target-directory --update=older -- "${dolphin_emu_sys_textures_dir?}" "${dolphin_emu_user_textures_dir?}"
else
    printf '%s\n' "Not copying HD textures because sys RSBE01 textures directory${dolphin_emu_sys_textures_ctime:+" (created $(date -d "$dolphin_emu_sys_textures_ctime"))"} was not created after user RSBE01 textures directory${dolphin_emu_user_textures_ctime:+" (created $(date -d "$dolphin_emu_user_textures_ctime"))"}"
fi

# Launch Dolphin with it pointed to the user directory via $DOLPHIN_EMU_USERPATH
exec project-plus-dolphin "$@"
